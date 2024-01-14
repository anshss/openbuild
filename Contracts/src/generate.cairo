#[starknet::contract]
mod Generate {
    use openzeppelin::introspection::src5::SRC5Component;
    use openzeppelin::access::accesscontrol::AccessControlComponent;
    use openzeppelin::upgrades::UpgradeableComponent;
    use openzeppelin::token::erc721::ERC721Component;

    component!(path: SRC5Component, storage: src5, event: SRC5Event);
    component!(path: AccessControlComponent, storage: accesscontrol, event: AccessControlEvent);
    component!(path: UpgradeableComponent, storage: upgradeable, event: UpgradeableEvent);
    component!(path: ERC721Component, storage: erc721, event: ERC721Event);

    #[abi(embed_v0)]
    impl SRC5Impl = SRC5Component::SRC5Impl<ContractState>;
    #[abi(embed_v0)]
    impl AccessControlImpl =
        AccessControlComponent::AccessControlImpl<ContractState>;
    #[abi(embed_v0)]
    impl ERC721Impl = ERC721Component::ERC721Impl<ContractState>;
    #[abi(embed_v0)]
    impl ERC721MetadataImpl = ERC721Component::ERC721MetadataImpl<ContractState>;

    impl AccessControlInternalImpl = AccessControlComponent::InternalImpl<ContractState>;
    impl UpgradeableInternalImpl = UpgradeableComponent::InternalImpl<ContractState>;
    impl ERC721InternalImpl = ERC721Component::InternalImpl<ContractState>;

    use contracts::interface::IGenerate;
    use core::traits::Into;
    use core::traits::TryInto;
    use array::ArrayTrait;
    use option::OptionTrait;
    use serde::Serde;
    use box::BoxTrait;
    use starknet::{
        get_caller_address, get_contract_address, ContractAddress, ClassHash,
        contract_address_to_felt252
    };

    mod Errors {
        const ZERO_ADDRESS: felt252 = 'Zero address error';
        const INVALID_URI: felt252 = 'Invalid URI provided';
        const INVALID_NAME: felt252 = 'Invalid name provided';
        const INVALID_CHARACTER_ID: felt252 = 'Invalid character ID';
        const INVALID_GENERATION_ID: felt252 = 'Invalid generation Id';
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        AccessControlEvent: AccessControlComponent::Event,
        SRC5Event: SRC5Component::Event,
        ERC721Event: ERC721Component::Event,
        UpgradeableEvent: UpgradeableComponent::Event,
        CharacterCreation: CharacterCreation,
        GenerationCreation: GenerationCreation,
        PublishGeneration: PublishGeneration,
    }

    #[derive(Drop, starknet::Event)]
    struct CharacterCreation {
        #[key]
        character_id: u256,
        #[key]
        user_address: ContractAddress
    }

    #[derive(Drop, starknet::Event)]
    struct GenerationCreation {
        #[key]
        character_id: u256,
        #[key]
        generation_id: u256,
        #[key]
        user_address: ContractAddress
    }

    #[derive(Drop, starknet::Event)]
    struct PublishGeneration {
        #[key]
        generation_id: u256,
        #[key]
        to: ContractAddress
    }

    #[derive(Drop, Serde, starknet::Store)]
    struct Character {
        character_id: u256,
        charater_name: felt252,
        uri: felt252,
        is_sale: bool,
        price: u256,
    }

    #[derive(Drop, Serde, starknet::Store)]
    struct Generation {
        generation_id: u256,
        character_id: u256,
        is_posted: bool,
        uri: felt252,
    }

    #[storage]
    struct Storage {
        #[substorage(v0)]
        src5: SRC5Component::Storage,
        #[substorage(v0)]
        accesscontrol: AccessControlComponent::Storage,
        #[substorage(v0)]
        upgradeable: UpgradeableComponent::Storage,
        #[substorage(v0)]
        erc721: ERC721Component::Storage,
        admin: ContractAddress,
        character_id: u256,
        generation_id: u256,
        chartacter_id_to_character: LegacyMap::<u256, Character>,
        user_characters: LegacyMap::<(ContractAddress, u256), u256>,
        user_character_length: LegacyMap::<ContractAddress, u256>,
        generation_id_to_generation: LegacyMap::<u256, Generation>,
        character_to_generations: LegacyMap::<(u256, u256), u256>,
        character_generation_length: LegacyMap::<u256, u256>,
    }

    #[constructor]
    fn constructor(ref self: ContractState, admin: ContractAddress,) {
        assert(!admin.is_zero(), Errors::ZERO_ADDRESS);
        self.accesscontrol.initializer();
        self._set_admin(admin);
        self.accesscontrol._grant_role('DEFAULT_ADMIN_ROLE', admin);
    }

    #[external(v0)]
    impl Generate of IGenerate<ContractState> {
        fn create_character(
            ref self: ContractState, uri: felt252, character_name: felt252
        ) -> u256 {
            assert(!uri.is_zero(), Errors::INVALID_URI);
            assert(!character_name.is_zero(), Errors::INVALID_NAME);
            self.character_id.write(self.current_character_id() + 1);
            self
                .chartacter_id_to_character
                .write(
                    self.current_character_id(),
                    Character {
                        character_id: self.current_character_id(),
                        charater_name: character_name,
                        uri: uri,
                        is_sale: false,
                        price: 0
                    }
                );
            self
                .user_characters
                .write(
                    (get_caller_address(), self.user_character_length.read(get_caller_address())),
                    self.current_character_id()
                );

            self
                .user_character_length
                .write(
                    get_caller_address(), self.user_character_length.read(get_caller_address()) + 1
                );
            self
                .emit(
                    CharacterCreation {
                        character_id: self.current_character_id(),
                        user_address: get_caller_address()
                    }
                );
            return self.current_character_id();
        }

        fn create_generation(ref self: ContractState, character_id: u256, uri: felt252) -> u256 {
            assert(
                character_id <= self.current_character_id() && character_id > 0,
                Errors::INVALID_CHARACTER_ID
            );
            assert(!uri.is_zero(), Errors::INVALID_URI);
            self.generation_id.write(self.current_generation_id() + 1);
            self
                .generation_id_to_generation
                .write(
                    self.current_generation_id(),
                    Generation {
                        generation_id: self.current_generation_id(),
                        character_id: character_id,
                        is_posted: false,
                        uri: uri,
                    }
                );
            self
                .character_to_generations
                .write(
                    (character_id, self.character_generation_length.read(character_id)),
                    self.current_generation_id()
                );
            self
                .character_generation_length
                .write(character_id, self.character_generation_length.read(character_id) + 1);
            self
                .emit(
                    GenerationCreation {
                        character_id: character_id,
                        generation_id: self.current_generation_id(),
                        user_address: get_caller_address()
                    }
                );
            return self.current_generation_id();
        }

        fn publish_generation(ref self: ContractState, generation_id: u256) {
            assert(
                generation_id <= self.current_character_id() && generation_id > 0,
                Errors::INVALID_GENERATION_ID
            );
            self
                .generation_id_to_generation
                .write(
                    generation_id,
                    Generation {
                        generation_id: generation_id,
                        character_id: self
                            .generation_id_to_generation
                            .read(generation_id)
                            .character_id,
                        is_posted: true,
                        uri: self.generation_id_to_generation.read(generation_id).uri,
                    }
                );
            self.erc721._mint(get_caller_address(), generation_id);
            let mut uri: felt252 = self.generation_id_to_generation.read(generation_id).uri;
            self.erc721._set_token_uri(generation_id, uri);
            self.emit(PublishGeneration { generation_id: generation_id, to: get_caller_address() });
        }

        fn get_user_characters(
            self: @ContractState, user_address: ContractAddress
        ) -> Array<Character> {
            assert(!user_address.is_zero(), Errors::ZERO_ADDRESS);
            let mut user_all_characters = ArrayTrait::<Character>::new();
            let mut len: u256 = self.user_character_length.read(user_address);
            let mut i: u256 = 0;
            loop {
                if (i >= len) {
                    break;
                }
                let mut character: Character = self
                    .chartacter_id_to_character
                    .read(self.user_characters.read((user_address, i)));
                user_all_characters.append(character);
                i += 1;
            };
            return user_all_characters;
        }

        fn get_generations_by_character_id(
            self: @ContractState, character_id: u256
        ) -> Array<Generation> {
            assert(
                character_id <= self.current_character_id() && character_id > 0,
                Errors::INVALID_CHARACTER_ID
            );
            let mut generations = ArrayTrait::<Generation>::new();
            let mut len: u256 = self.character_generation_length.read(character_id);
            let mut i: u256 = 0;
            loop {
                if (i >= len) {
                    break;
                }
                let mut generation_id: u256 = self.character_to_generations.read((character_id, i));
                let mut generation: Generation = self
                    .generation_id_to_generation
                    .read(generation_id);
                generations.append(generation);
                i += 1;
            };
            return generations;
        }

        fn current_character_id(self: @ContractState) -> u256 {
            self.character_id.read()
        }

        fn current_generation_id(self: @ContractState) -> u256 {
            self.generation_id.read()
        }

        fn get_admin(self: @ContractState) -> ContractAddress {
            self.admin.read()
        }

        fn upgrade(ref self: ContractState, new_class_hash: ClassHash) {
            self.accesscontrol.assert_only_role('DEFAULT_ADMIN_ROLE');
            self.upgradeable._upgrade(new_class_hash);
        }

        fn update_admin(ref self: ContractState, new_admin: ContractAddress) {
            self.accesscontrol.assert_only_role('DEFAULT_ADMIN_ROLE');
            assert(!new_admin.is_zero(), Errors::ZERO_ADDRESS);
            let old_admin: ContractAddress = self.get_admin();
            self.accesscontrol._grant_role('DEFAULT_ADMIN_ROLE', new_admin);
            self._set_admin(new_admin);
            self.accesscontrol._revoke_role('DEFAULT_ADMIN_ROLE', old_admin);
        }
    }
    #[generate_trait]
    impl Private of PrivateTrait {
        fn _set_admin(ref self: ContractState, _admin: ContractAddress) {
            assert(!_admin.is_zero(), Errors::ZERO_ADDRESS);
            self.admin.write(_admin);
        }
    }
}

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
    }
    const DECIMALS: u256 = 1000000000000000000;

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
        stream_id: felt252,
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
        user_to_characters: LegacyMap::<(ContractAddress, u256), Character>,
        character_length: LegacyMap::<ContractAddress, u256>,
    // character_to_generation: LegacyMap::<u256, Generation>,
    }


    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        AccessControlEvent: AccessControlComponent::Event,
        SRC5Event: SRC5Component::Event,
        ERC721Event: ERC721Component::Event,
        UpgradeableEvent: UpgradeableComponent::Event,
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
                .user_to_characters
                .write(
                    (get_caller_address(), self.current_character_id()),
                    Character {
                        character_id: self.current_character_id(),
                        charater_name: character_name,
                        uri: uri,
                        is_sale: false,
                        price: 0
                    }
                );
            self
                .character_length
                .write(get_caller_address(), self.character_length.read(get_caller_address()) + 1);
            return self.current_character_id();
        }

        // fn get_user_characters(
        //     self: @ContractState, user_address: ContractAddress
        // ) -> Array<Character> {
        //     assert(!user_address.is_zero(), Errors::ZERO_ADDRESS);
        // }

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

        fn current_character_id(self: @ContractState) -> u256 {
            self.character_id.read()
        }


        fn get_admin(self: @ContractState) -> ContractAddress {
            self.admin.read()
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

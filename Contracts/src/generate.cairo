#[starknet::contract]
mod Generate {
    use openzeppelin::access::accesscontrol::accesscontrol::AccessControlComponent::InternalTrait;
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

    // Hack to simulate the 'crate' keyword
    use super::super as crate;
    use crate::igenerate::IGenerate;
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
    }
    const DECIMALS: u256 = 1000000000000000000;

    #[derive(Drop, Serde, starknet::Strore)]
    struct Character {
        character_id: u256,
        charater_name: felt252,
        uri: felt252,
        is_sale: bool,
        prive: u256
    }

    #[derive(Drop, Serde, starknet::Strore)]
    struct Generation {
        generation_id: u256,
        character_id: u256,
        is_posted: bool,
        stream_id: felt252
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
        charater_id: u256,
    // This mapping should return character array when given a address
    // user_to_characters: LegacyMap::<ContractAddress, u256>,
    // character_to_generations: LegacyMap::<u256, ContractAddress>,
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
        fn upgrade(ref self: ContractState, new_class_hash: ClassHash) {
            self.accesscontrol.assert_only_role('DEFAULT_ADMIN_ROLE');
            self.upgradeable._upgrade(new_class_hash);
        }

        fn update_admin(ref self: ContractState, new_admin: ContractAddress) {
            assert(!new_admin.is_zero(), Errors::ZERO_ADDRESS);
            let old_admin: ContractAddress = self.get_admin();
            self.accesscontrol._grant_role('DEFAULT_ADMIN_ROLE', new_admin);
            self._set_admin(new_admin);
            self.accesscontrol._revoke_role('DEFAULT_ADMIN_ROLE', old_admin);
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

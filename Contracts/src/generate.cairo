#[starknet::interface]
trait IGenerate<TContractState> {}


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

    impl AccessControlInternalImpl = AccessControlComponent::InternalImpl<ContractState>;
    impl UpgradeableInternalImpl = UpgradeableComponent::InternalImpl<ContractState>;

    #[abi(embed_v0)]
    impl ERC721Impl = ERC721Component::ERC721Impl<ContractState>;
    #[abi(embed_v0)]
    impl ERC721MetadataImpl = ERC721Component::ERC721MetadataImpl<ContractState>;

    impl ERC721InternalImpl = ERC721Component::InternalImpl<ContractState>;


    use core::traits::Into;
    use core::traits::TryInto;
    use contracts::generate::IGenerate;
    use array::ArrayTrait;
    use option::OptionTrait;
    use serde::Serde;
    use box::BoxTrait;
    use starknet::{
        get_caller_address, get_contract_address, ContractAddress, ClassHash,
        contract_address_to_felt252
    };


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
    fn constructor(ref self: ContractState, owner: ContractAddress,) {
        assert(!owner.is_zero(), 'Owner is zero address!');
        self.accesscontrol._grant_role('DEFAULT_ADMIN_ROLE', owner);
    }
    


// #[generate_trait]
// impl Private of PrivateTrait {
//     fn _only_admin(self: @ContractState) -> () {
//         let unsafe_state = Ownable::unsafe_new_contract_state();
//         Ownable::InternalImpl::assert_only_owner(@unsafe_state);
//     }
// }
}

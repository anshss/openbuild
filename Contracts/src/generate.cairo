use starknet::ContractAddress;
use starknet::ClassHash;
use starknet::get_block_timestamp;

#[starknet::interface]
trait IGenerate<TContractState> {}

#[starknet::interface]
trait IUpgradeable<TContractState> {
    fn upgrade(ref self: TContractState, new_class_hash: ClassHash);
}

#[starknet::interface]
trait IOwnable<TContractState> {
    fn owner(self: @TContractState) -> ContractAddress;
    fn transfer_ownership(ref self: TContractState, new_owner: ContractAddress);
    fn renounce_ownership(ref self: TContractState);
}

#[starknet::contract]
mod Generate {
    use openzeppelin::upgrades::interface::IUpgradeable;
    use openzeppelin::upgrades::upgradeable::Upgradeable;
    use openzeppelin::access::ownable::interface::IOwnable;
    use openzeppelin::access::ownable::ownable::Ownable;
    use core::traits::Into;
    use starknet::ClassHash;
    use starknet::contract_address_to_felt252;
    use core::traits::TryInto;
    use Contracts::generate::IGenerate;
    use starknet::get_caller_address;
    use starknet::get_contract_address;
    use starknet::ContractAddress;
    use array::ArrayTrait;
    use option::OptionTrait;
    use serde::Serde;
    use box::BoxTrait;

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
        charater_id: u256,
        // This mapping should return character array when given a address
        // user_to_characters: LegacyMap::<ContractAddress, u256>,
        // character_to_generations: LegacyMap::<u256, ContractAddress>,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {}

    #[constructor]
    fn constructor(ref self: ContractState, owner: ContractAddress,) {
        assert(!owner.is_zero(), 'Owner is zero address!');
        let mut unsafe_state = Ownable::unsafe_new_contract_state();
        Ownable::InternalImpl::initializer(ref unsafe_state, owner);
    }

    // Upgradability
    #[external(v0)]
    impl UpgradeableImpl of IUpgradeable<ContractState> {
        fn upgrade(ref self: ContractState, new_class_hash: ClassHash) {
            self._only_admin();
            let mut unsafe_state = Upgradeable::unsafe_new_contract_state();
            Upgradeable::InternalImpl::_upgrade(ref unsafe_state, new_class_hash)
        }
    }

    // Access Control
    #[external(v0)]
    impl OwnableImpl of IOwnable<ContractState> {
        fn owner(self: @ContractState) -> ContractAddress {
            let unsafe_state = Ownable::unsafe_new_contract_state();
            Ownable::OwnableImpl::owner(@unsafe_state)
        }

        fn transfer_ownership(ref self: ContractState, new_owner: ContractAddress) {
            let mut unsafe_state = Ownable::unsafe_new_contract_state();
            Ownable::OwnableImpl::transfer_ownership(ref unsafe_state, new_owner)
        }

        fn renounce_ownership(ref self: ContractState) {
            assert(true == false, 'renounce_ownership is disabled');
        }
    }

    #[generate_trait]
    impl Private of PrivateTrait {
        fn _only_admin(self: @ContractState) -> () {
            let unsafe_state = Ownable::unsafe_new_contract_state();
            Ownable::InternalImpl::assert_only_owner(@unsafe_state);
        }
    }
}

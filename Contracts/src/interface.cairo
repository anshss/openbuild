use starknet::{ContractAddress, ClassHash};
use contracts::generate::Generate::Character;
use contracts::generate::Generate::Generation;

#[starknet::interface]
trait IGenerate<TContractState> {
    fn create_character(ref self: TContractState, uri: felt252, character_name: felt252) -> u256;
    fn create_generation(ref self: TContractState, character_id: u256, uri: felt252) -> u256;
    fn publish_generation(ref self: TContractState, generation_id: u256);
    fn get_user_characters(
        self: @TContractState, user_address: ContractAddress
    ) -> Array<Character>;
    fn get_generations_by_character_id(
        self: @TContractState, character_id: u256
    ) -> Array<Generation>;
    fn current_character_id(self: @TContractState) -> u256;
    fn current_generation_id(self: @TContractState) -> u256;
    fn upgrade(ref self: TContractState, new_class_hash: ClassHash);
    fn get_admin(self: @TContractState) -> ContractAddress;
    fn update_admin(ref self: TContractState, new_admin: ContractAddress);
}

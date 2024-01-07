use starknet::{ContractAddress, ClassHash};

#[starknet::interface]
trait IGenerate<TContractState> {
    fn upgrade(ref self: TContractState, new_class_hash: ClassHash);
    fn get_admin(self: @TContractState) -> ContractAddress;
    fn update_admin(ref self: TContractState, new_admin: ContractAddress);
}

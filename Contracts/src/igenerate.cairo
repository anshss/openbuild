use starknet::{ContractAddress, ClassHash,};

#[starknet::interface]
trait IGenerate<TContractState> {
    fn upgrade(ref self: TContractState, new_class_hash: ClassHash);
}

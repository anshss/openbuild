const {
    Account,
    json,
    num,
    RpcProvider,
} = require("starknet");
const fs = require("fs");
require("dotenv").config();

async function main() {
    const NODE_RPC_URL = process.env.rpc
    const provider = new RpcProvider({ nodeUrl: `${NODE_RPC_URL}` });
    const privateKey = process.env.privateKey1;
    const accountAddress = process.env.accountAddress;

    const account = new Account(provider, accountAddress, privateKey);

    let generate_address = await declareAndDeployGenerate(account);

    let addressObj = {
        generate_address,
    };

    await writeAddressesToJson(addressObj);
}

main();


async function declareAndDeployGenerate(account) {
    console.log("declareAndDeployGenerate start")
    const compiledTestSierra = json.parse(
        fs.readFileSync("./target/dev/contracts_Generate.contract_class.json").toString("ascii")
    );
    const compiledTestCasm = json.parse(
        fs.readFileSync("./target/dev/contracts_Generate.compiled_contract_class.json").toString("ascii")
    );
    const deployResponse = await account.declareAndDeploy({
        contract: compiledTestSierra,
        casm: compiledTestCasm,
        constructorCalldata: [
            num.hexToDecimalString(account.address),
            "18254", 
            "18254",
        ],
    });

    console.log("deployed Generate at: ", deployResponse.deploy.contract_address);
    console.log("------- declareAndDeployGenerate completed -------");

    return deployResponse.deploy.contract_address;
}

async function writeAddressesToJson(addressObj) {
    const data = JSON.stringify(addressObj);

    fs.writeFile("contract_addreses.json", data, (error) => {
        if (error) {
            console.error(error);
            throw error;
        }
        console.log("data.json written correctly");
    });
}


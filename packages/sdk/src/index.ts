// linkedpm SDK

import { ethers, providers, Signer } from "ethers";
const { Provider, BaseProvider } = providers;
import { keccak256 } from "ethers/lib/utils";
import { DocRegistry } from "../types/DocRegistry";
import { DocRegistry__factory } from "../types/factories/DocRegistry__factory";
import { DocRegistryL2__factory } from "../types/factories/DocRegistryL2__factory";
import { DocRegistryL2 } from "../types/DocRegistryL2";
import { l1, l2 } from "./abi";

import { CID } from "multiformats/cid";
import { sha256 } from "multiformats/hashes/sha2";
import { base64 } from "multiformats/bases/base64";

import addresses from "../src/addresses";
interface ReadConfig {
  contract?: DocRegistry | DocRegistryL2 | string;
  provider: InstanceType<typeof Provider>;
}
interface WriteConfig {
  contract?: DocRegistry | DocRegistryL2 | string;
  signer: Signer;
}

async function fetchMetadata(
  zone: string,
  key: string,
  revision: string,
  config?: ReadConfig
) {
  if (!config) {
    config = {
      provider: new ethers.providers.JsonRpcProvider(
        "https://rpc.ankr.com/eth"
      ),
    };
  }

  // fetch metadata from the smart contract
  const contract = await resolveContract(config.contract, config.provider);

  if (contract.contractName == "DocRegistry") {
    return await contract.zoneAgreement(
      keccak256(zone),
      keccak256(key),
      keccak256(revision)
    );
  } else if (contract.contractName == "DocRegistryL2") {
    return await contract["zoneAgreement(bytes32,bytes32,bytes32)"](
      keccak256(zone),
      keccak256(key),
      keccak256(revision)
    );
  }
}

// Check registry type
async function checkRegistryL1(
  address: string,
  provider: InstanceType<typeof Provider>
) {
  let contract = new ethers.Contract(address, l1, provider) as DocRegistry;

  // both L1 & L2 registry types have registryType() which return either 1 or 2
  // 1 being L1, 2 being L2

  let r = await contract.registryType();

  if (r == 1) return true;

  return false;
}

async function createRevision(
  zone: string,
  key: string,
  revision: string,
  ipfsCid: string,
  config: WriteConfig
) {
  // fetch metadata from the smart contract
  const contract = await resolveContract(
    config.contract,
    config.signer.provider
  );

  await contract.updateAgreement(
    keccak256(zone),
    keccak256(key),
    keccak256(revision),
    ipfsCid
  );
}
async function claimZone(zone: string, config: WriteConfig) {
  // fetch metadata from the smart contract
  const contract = await resolveContract(
    config.contract,
    config.signer.provider
  );

  await contract.claimZone(zone);
}

async function resolveContract(
  contract: string | DocRegistry | DocRegistryL2,
  provider: InstanceType<typeof Provider>
) {
  // fetch metadata from the smart contract

  let { chainId } = await provider.getNetwork();

  let contractResult = contract;

  if (contractResult == undefined) {
    if (!addresses[chainId]) {
      throw new Error("No default address for contract could be located");
    }

    contractResult = DocRegistry__factory.connect(
      addresses[chainId.toString()].address,
      provider
    ) as DocRegistry;
  }

  if (typeof contractResult == "string") {
    const isL1 = checkRegistryL1(contractResult, provider);

    if (isL1) {
      contractResult = DocRegistry__factory.connect(contractResult, provider);
    } else {
      contractResult = DocRegistryL2__factory.connect(contractResult, provider);
    }
  }

  return contractResult;
}

export { fetchMetadata, createRevision, claimZone };

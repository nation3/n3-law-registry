// linkedpm SDK

import { ethers, providers, Signer } from "ethers";
const { Provider, BaseProvider } = providers;
import keccak256 from "keccak256";
import { DocRegistry } from "../types/DocRegistry";
import { DocRegistry__factory } from "../types/factories/DocRegistry__factory";
import { DocRegistryL2__factory } from "../types/factories/DocRegistryL2__factory";
import { DocRegistryL2 } from "../types/DocRegistryL2";

import addresses from "../src/addresses";
interface ReadConfig {
  contract?: DocRegistry | DocRegistryL2 | string;
  provider: InstanceType<typeof Provider>;
}
interface WriteConfig {
  contract?: DocRegistry | DocRegistryL2 | string;
  signer: Signer;
}

async function revisionData(
  zone: string,
  key: string,
  revision: string,
  config?: ReadConfig
): Promise<string> {
  if (!config.provider) {
    config = {
      ...config,
      provider: new ethers.providers.JsonRpcProvider(
        "https://rpc.ankr.com/eth"
      ),
    };
  }

  // fetch metadata from the smart contract
  const [contract, isL1] = await resolveContract(
    config.contract,
    config.provider
  );

  const values: [string, string, string] = [
    "0x" + keccak256(zone).toString("hex"),
    "0x" + keccak256(key).toString("hex"),
    "0x" + keccak256(revision).toString("hex"),
  ];

  if (isL1) {
    return await (contract as DocRegistry).zoneAgreement(...values);
  } else {
    return await contract["zoneAgreement(bytes32,bytes32,bytes32)"](...values);
  }
}

async function zoneOwner(zone: string, config?: ReadConfig) {
  if (!config.provider) {
    config = {
      ...config,
      provider: new ethers.providers.JsonRpcProvider(
        "https://rpc.ankr.com/eth"
      ),
    };
  }

  // fetch metadata from the smart contract
  const [contract] = await resolveContract(config.contract, config.provider);

  return await contract.zoneOwner(keccak256(zone));
}

// Check registry type
async function checkRegistryL1(
  address: string,
  provider: InstanceType<typeof Provider>
) {
  const contract = DocRegistry__factory.connect(address, provider);

  // both L1 & L2 registry types have registryType() which return either 1 or 2
  // 1 being L1, 2 being L2

  const r = await contract.connect(provider).registryType();

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
  const [rawContract, isL1] = await resolveContract(
    config.contract,
    config.signer.provider
  );

  const contract = rawContract.connect(config.signer);

  if (isL1) {
    await contract.updateAgreement(
      "0x" + keccak256(zone).toString("hex"),
      "0x" + keccak256(key).toString("hex"),
      revision,
      ipfsCid
    );
  } else {
    const l2Contract: DocRegistryL2 = contract as DocRegistryL2;

    await l2Contract.updateAgreement(
      await l2Contract.zoneID("0x" + keccak256(zone).toString("hex")),
      "0x" + keccak256(key).toString("hex"),
      revision,
      ipfsCid
    );
  }
}
async function claimZone(zone: string, config: WriteConfig) {
  // fetch metadata from the smart contract

  const contract = await resolveContract(
    config.contract,
    config.signer.provider
  );

  await contract[0].connect(config.signer).claimZone(zone);
}

async function resolveContract(
  contract: string | DocRegistry | DocRegistryL2,
  provider: InstanceType<typeof Provider>
) {
  // fetch metadata from the smart contract

  const { chainId } = await provider.getNetwork();

  let result = contract;

  let isL1 = true;

  if (result == undefined) {
    if (addresses[chainId.toString()] == undefined) {
      throw new Error("No default address for contract could be located");
    }

    isL1 = addresses[chainId.toString()].type == "l1";

    if (isL1) {
      result = DocRegistry__factory.connect(
        addresses[chainId.toString()].address,
        provider
      );
    } else {
      result = DocRegistryL2__factory.connect(
        addresses[chainId.toString()].address,
        provider
      );
    }
  }

  if (typeof result == "string") {
    isL1 = await checkRegistryL1(result, provider);
    if (isL1) {
      result = DocRegistry__factory.connect(result, provider);
    } else {
      result = DocRegistryL2__factory.connect(result, provider);
    }
  }

  return [result, isL1] as [DocRegistry | DocRegistryL2, boolean];
}

function resolvePath(path: string): [string, string, string] {
  // validate path
  // regex: ^([a-z0-9\-]{1,32})\/([a-z0-9\-]{1,32})(?:@([a-z0-9\-\._]{1,32})){0,1}$

  const regex =
    /^([a-z0-9\-]{1,32})\/([a-z0-9\-]{1,32})(?:@([a-z0-9\-\._]{1,32})){0,1}$/;

  let result: Array<string> = path.match(regex);

  if (result != null) {
    let [, zone, agreement, revision] = result;
    if (revision == undefined) revision = "latest";
    return [zone, agreement, revision];
  }

  return null;
}

export {
  revisionData,
  createRevision,
  claimZone,
  zoneOwner,
  resolveContract,
  resolvePath,
};

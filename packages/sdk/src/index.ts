// linkedpm SDK

import { ethers, providers, Signer } from "ethers";
const { Provider } = providers;
import { keccak256 } from "ethers/lib/utils";
import { DocRegistry } from "../types/DocRegistry";
import { DocRegistryL2 } from "../types/DocRegistryL2";

import { CID } from "multiformats/cid";
import { sha256 } from "multiformats/hashes/sha2";
import { base64 } from "multiformats/bases/base64";

interface ReadConfig {
  contract: DocRegistry | DocRegistryL2;
  provider: typeof Provider;
}
interface WriteConfig {
  contract: DocRegistry | DocRegistryL2;
  provider: Signer;
}

interface Metadata {}

async function fetchMetadata(
  zone: string,
  key: string,
  revision: string,
  config?: ReadConfig
) {
  // fetch metadata from the smart contract

  if (config.contract.contractName == "DocRegistry") {
    return await config.contract.zoneAgreement(
      keccak256(zone),
      keccak256(key),
      keccak256(revision)
    );
  } else if (config.contract.contractName == "DocRegistryL2") {
    return await config.contract["zoneAgreement(bytes32,bytes32,bytes32)"](
      keccak256(zone),
      keccak256(key),
      keccak256(revision)
    );
  }
}

async function createRevision(
  zone: string,
  key: string,
  revision: string,
  ipfsCid: string,
  config: WriteConfig
) {
  await config.contract.updateAgreement(
    keccak256(zone),
    keccak256(key),
    keccak256(revision),
    ipfsCid
  );
}
async function claimZone(zone: string, config: WriteConfig) {
  await config.contract.connect(config.provider).claimZone(zone);
}

export { fetchMetadata, createRevision, claimZone };

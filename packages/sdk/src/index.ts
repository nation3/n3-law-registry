// linkedpm SDK

import { BaseContract, ethers } from "ethers";

interface FetchMetadataConfig {
  contract: BaseContract;
}

function fetchMetadata(zone: string, key: string, revision: string) {
  // fetch data from the smart contract
}

function createRevision(zone: string, key: string, revision: string) {}
function claimZone(zone: string) {}

export { fetchMetadata, createRevision, claimZone };

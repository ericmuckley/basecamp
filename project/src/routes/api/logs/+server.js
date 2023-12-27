import { decodeEventLog, hexToBigInt } from "viem";
import { PRIVATE_BASESCAN_API_KEY } from "$env/static/private";
import {
  CONTRACT_ADDRESS,
  CONTRACT_METADATA,
  BLOCK_EXPLORER_API_URL,
} from "$lib/contract_settings.js";

const displayTimestamp = (unixTimestamp) => {
  const MONTHS = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec",
  ];
  const d = new Date(Number(unixTimestamp) * 1000);
  const timestamp = `${d.getDate()} ${
    MONTHS[d.getMonth()]
  } ${d.getFullYear()} ${String(d.getHours()).padStart(2, "0")}:${String(d.getMinutes()).padStart(2, "0")}:${String(d.getSeconds()).padStart(2, "0")}`;
  console.log(timestamp)
  return timestamp;
};

const getLogs = async () => {
  let logs = [];
  let url = `${BLOCK_EXPLORER_API_URL}api?module=logs&action=getLogs&address=${CONTRACT_ADDRESS}&startBlock=0&endblock=9999999999999999999999999999999999999999999999999999999999&sort=desc&apikey=${PRIVATE_BASESCAN_API_KEY}`;
  let res = await (await fetch(url)).json();
  if (res.status === "1" && res.message === "OK") {
    let txns = res.result;
    let abi = CONTRACT_METADATA.output.abi;
    for (let txn of txns) {
      const decodedEvent = decodeEventLog({
        abi: abi,
        data: txn.data,
        topics: txn.topics,
      });
      decodedEvent.timestamp = displayTimestamp(hexToBigInt(txn.timeStamp));
      for (const [k, v] of Object.entries(decodedEvent.args)) {
        if (typeof v === "bigint") {
          decodedEvent.args[k] = Number[v];
        }
      }
      logs.push({ ...txn, ...decodedEvent });
    }
  }
  logs.sort((a, b) => b.blockNumber - a.blockNumber);
  return logs;
};

export async function GET() {
  let logs = await getLogs();
  return new Response(JSON.stringify({ logs }));
}

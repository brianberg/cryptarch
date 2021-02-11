const CURRENCIES = {
  "AAVE": {
    "symbol": "AAVE",
    "name": "Aave",
    "type": "token",
    "icon": "assets/images/currencies/aave.svg",
    "default": false,
    "exchanges": [
      "Kraken",
    ],
  },
  "ADA": {
    "symbol": "ADA",
    "name": "Cardano",
    "type": "coin",
    "icon": "assets/images/currencies/ada.svg",
    "default": true,
    "exchanges": [
      "Kraken",
    ],
  },
  "ALGO": {
    "symbol": "ALGO",
    "name": "Algorand",
    "type": "coin",
    "icon": "assets/images/currencies/algo.svg",
    "default": false,
    "exchanges": [
      "Kraken",
    ],
  },
  "BAND": {
    "symbol": "BAND",
    "name": "Band Protocol",
    "type": "token",
    "icon": "assets/images/currencies/band.svg",
    "default": false,
    "exchanges": [
      "Kraken",
    ],
  },
  "BAT": {
    "symbol": "BAT",
    "name": "Basic Attention Token",
    "type": "token",
    "icon": "assets/images/currencies/bat.svg",
    "default": false,
    "exchanges": [
      "Kraken",
    ],
  },
  "BCH": {
    "symbol": "BCH",
    "name": "Bitcoin Cash",
    "type": "coin",
    "icon": "assets/images/currencies/bch.svg",
    "default": false,
    "exchanges": [
      "Kraken",
    ],
  },
  "BEAM": {
    "symbol": "BEAM",
    "name": "Beam",
    "type": "coin",
    "icon": "assets/images/currencies/beam.svg",
    "default": false,
    "exchanges": [
      "Kraken",
    ],
  },
  "BNB": {
    "symbol": "BNB",
    "name": "Binance Coin",
    "type": "coin",
    "icon": "assets/images/currencies/bnb.svg",
    "default": false,
    "exchanges": [
      "Kraken",
    ],
  },
  "BSV": {
    "symbol": "BSV",
    "name": "Bitcoin SV",
    "type": "coin",
    "icon": "assets/images/currencies/bsv.svg",
    "default": false,
    "exchanges": [
      "Kraken",
    ],
  },
  "BTC": {
    "symbol": "BTC",
    "name": "Bitcoin",
    "type": "coin",
    "icon": "assets/images/currencies/btc.svg",
    "default": true,
    "exchanges": [
      "Kraken",
    ],
  },
  "DAI": {
    "symbol": "DAI",
    "name": "Dai",
    "type": "token",
    "icon": "assets/images/currencies/dai.svg",
    "default": false,
    "exchanges": [
      "Kraken",
    ],
  },
  "DASH": {
    "symbol": "DASH",
    "name": "Dash",
    "type": "coin",
    "icon": "assets/images/currencies/dash.svg",
    "default": false,
    "exchanges": [
      "Kraken",
    ],
  },
  "DOGE": {
    "symbol": "DOGE",
    "name": "Dogecoin",
    "type": "coin",
    "icon": "assets/images/currencies/doge.svg",
    "default": false,
    "exchanges": [
      "Kraken",
    ],
  },
  "DOT": {
    "symbol": "DOT",
    "name": "Polkadot",
    "type": "coin",
    "icon": "assets/images/currencies/dot.svg",
    "default": false,
    "exchanges": [
      "Kraken",
    ],
  },
  "EOS": {
    "symbol": "EOS",
    "name": "EOS",
    "type": "coin",
    "icon": "assets/images/currencies/eos.svg",
    "default": false,
    "exchanges": [
      "Kraken",
    ],
  },
  "ETC": {
    "symbol": "ETC",
    "name": "Ethereum Classic",
    "type": "coin",
    "icon": "assets/images/currencies/etc.svg",
    "default": false,
    "exchanges": [
      "Kraken",
    ],
  },
  "ETH": {
    "symbol": "ETH",
    "name": "Ethereum",
    "type": "coin",
    "icon": "assets/images/currencies/eth.svg",
    "default": true,
    "exchanges": [
      "Kraken",
    ],
  },
  "FIL": {
    "symbol": "FIL",
    "name": "Filecoin",
    "type": "coin",
    "icon": "assets/images/currencies/fil.svg",
    "default": false,
    "exchanges": [
      "Kraken",
    ],
  },
  "GRIN": {
    "symbol": "GRIN",
    "name": "Grin",
    "type": "coin",
    "icon": "assets/images/currencies/grin.svg",
    "default": false,
    "exchanges": [
      "Kraken",
    ],
  },
  "KNC": {
    "symbol": "KNC",
    "name": "Kyber Network",
    "type": "token",
    "icon": "assets/images/currencies/knc.svg",
    "default": false,
    "exchanges": [
      "Kraken",
    ],
  },
  "LINK": {
    "symbol": "LINK",
    "name": "Chainlink",
    "type": "token",
    "icon": "assets/images/currencies/link.svg",
    "default": false,
    "exchanges": [
      "Kraken",
    ],
  },
  "LTC": {
    "symbol": "LTC",
    "name": "Litecoin",
    "type": "coin",
    "icon": "assets/images/currencies/ltc.svg",
    "default": true,
    "exchanges": [
      "Kraken",
    ],
  },
  "MEME": {
    "symbol": "MEME",
    "name": "Meme",
    "type": "token",
    "blockchain": "Ethereum",
    "contractAddress": "0xd5525d397898e5502075ea5e830d8914f6f0affe",
    "icon": "assets/images/currencies/meme.png",
    "default": false,
  },
  "MKR": {
    "symbol": "MKR",
    "name": "Maker",
    "type": "token",
    "icon": "assets/images/currencies/mkr.svg",
    "default": false,
    "exchanges": [
      "Coinbase Pro",
    ],
  },
  "OXT": {
    "symbol": "OXT",
    "name": "Orchid",
    "type": "token",
    "icon": "assets/images/currencies/oxt.svg",
    "default": false,
    "exchanges": [
      "Kraken",
    ],
  },
  "REP": {
    "symbol": "REP",
    "name": "Augur",
    "type": "token",
    "icon": "assets/images/currencies/rep.svg",
    "default": false,
    "exchanges": [
      "Kraken",
    ],
  },
  "RVN": {
    "symbol": "RVN",
    "name": "Ravencoin",
    "type": "coin",
    "icon": "assets/images/currencies/rvn.svg",
    "default": false,
    "exchanges": [
      "Bittrex",
    ],
  },
  "STMX": {
    "symbol": "STMX",
    "name": "StormX",
    "type": "token",
    "icon": "assets/images/currencies/stmx.svg",
    "default": false,
    "exchanges": [
      "Kraken",
    ],
  },
  "UNI": {
    "symbol": "UNI",
    "name": "Uniswap",
    "type": "token",
    "icon": "assets/images/currencies/uni.svg",
    "default": false,
    "exchanges": [
      "Kraken",
    ],
  },
  "USD": {
    "symbol": "USD",
    "name": "United States Dollar",
    "type": "fiat",
    "icon": "assets/images/currencies/usd.svg",
    "default": true,
  },
  "USDC": {
    "symbol": "USDC",
    "name": "USD Coin",
    "type": "token",
    "icon": "assets/images/currencies/usdc.svg",
    "default": false,
    "exchanges": [
      "Kraken",
    ],
  },
  "USDT": {
    "symbol": "USDT",
    "name": "Tether",
    "type": "token",
    "icon": "assets/images/currencies/usdt.svg",
    "default": false,
    "exchanges": [
      "Kraken",
    ],
  },
  "WBTC": {
    "symbol": "WBTC",
    "name": "Wrapped Bitcoin",
    "type": "token",
    "icon": "assets/images/currencies/wbtc.svg",
    "default": false,
    "exchanges": [
      "Kraken",
    ],
  },
  "XLM": {
    "symbol": "XLM",
    "name": "Stellar Lumens",
    "type": "coin",
    "icon": "assets/images/currencies/xlm.svg",
    "default": true,
    "exchanges": [
      "Kraken",
    ],
  },
  "XMR": {
    "symbol": "XMR",
    "name": "Monero",
    "type": "coin",
    "icon": "assets/images/currencies/xmr.svg",
    "default": true,
    "exchanges": [
      "Kraken",
    ],
  },
  "XRP": {
    "symbol": "XRP",
    "name": "XRP",
    "type": "coin",
    "icon": "assets/images/currencies/xrp.svg",
    "default": true,
    "exchanges": [
      "Kraken",
    ],
  },
  "XTZ": {
    "symbol": "XTZ",
    "name": "Tezos",
    "type": "coin",
    "icon": "assets/images/currencies/xtz.svg",
    "default": true,
    "exchanges": [
      "Kraken",
    ],
  },
  "ZEC": {
    "symbol": "ZEC",
    "name": "Zcash",
    "type": "coin",
    "icon": "assets/images/currencies/zec.svg",
    "default": true,
    "exchanges": [
      "Kraken",
    ],
  },
  "ZRX": {
    "symbol": "ZRX",
    "name": "0x",
    "type": "token",
    "icon": "assets/images/currencies/zrx.svg",
    "default": true,
    "exchanges": [
      "Coinbase Pro",
    ],
  },
};

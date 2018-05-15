defmodule POAAgent.Ancillary.Entity do
  @moduledoc false

  alias POAAgent.Entity.Host
  alias POAAgent.Entity.Ethereum

  def information do
    %Host.Information{
    }
  end

  def block do
    %Ethereum.Block{
      "author": "0xdf9c9701e434c5c9f755ef8af18d6a4336550206",
      "difficulty": "340282366920938463463374607431768211453",
      "extra_data": "0xd583010a008650617269747986312e32342e31826c69",
      "gas_limit": 8_000_000,
      "gas_used": 0,
      "hash": "0x542d1caaf98eb4e19ffd87fa86548efde7ee5b8cc375d08f5c1cc0326441979a",
      "miner": "0xdf9c9701e434c5c9f755ef8af18d6a4336550206",
      "number": 244_589,
      "parent_hash": "0x8f59cb9abfa6e4c3c5a7827d9673e781dad41424e9f79843b189fa28c21aa3fa",
      "receipts_root": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421",
      "seal_fields": [
        "0x841230e253",
        "0xb841b833205a08faeb4a5ed3d76627044bf4af7e0685d3d3bb5cd29be1fb5f8ed7ec49d09f93aa68da602bb5b8cfbcd128ac52a293fb52e0b9caca4de0196c6bf35d01"
      ],
      "sha3_uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347",
      "signature": "b833205a08faeb4a5ed3d76627044bf4af7e0685d3d3bb5cd29be1fb5f8ed7ec49d09f93aa68da602bb5b8cfbcd128ac52a293fb52e0b9caca4de0196c6bf35d01",
      "size": 579,
      "state_root": "0x7b32995a55db34bd1a5e583afeb48e114908bc6c0eca5d1c2dcd9fe1bfffaefe",
      "step": "305193555",
      "timestamp": 1_525_967_775,
      "total_difficulty": "83229323842825417840043331857128754766504512",
      "transactions": [

      ],
      "transactions_root": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421",
      "uncles": [

      ]
    }
  end

  def statistics do
    %Ethereum.Statistics{
      "active?": true,
      "syncing?": false,
      "mining?": false,
      "hashrate": 0,
      "peers": 3,
      "gas_price": "1000000000",
      "uptime": 100
    }
  end

  def history do
    [Map.from_struct(block())]
  end
end

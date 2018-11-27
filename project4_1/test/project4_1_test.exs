defmodule Project1Test do
  use ExUnit.Case

  test "Hash correctness" do
    assert "60C6ABBFD0F146F9CD5173E79EF56E69787F6B7CB00A83F4E049FFA7B625B12F" ==
      Hashing.bitcoinHasher("elixir")

    assert "6B88C087247AA2F07EE1C5956B8E1A9F4C7F892A70E324F1BB3D161E05CA107B" ==
      Hashing.bitcoinHasher("bitcoin")

    assert "EF7797E13D3A75526946A3BCF00DAEC9FC9C9C4D51DDC7CC5DF888F74DD434D1" ==
      Hashing.bitcoinHasher("blockchain")

    assert "E8D44050873DBA865AA7C170AB4CCE64D90839A34DCFD6CF71D14E0205443B1B" ==
      Hashing.bitcoinHasher("wallet")
  end

  describe "Transaction Correctness" do
    test "Transaction Success" do
     {senderBTC, receiverBTC, status} = MainServer.doTransactions(100,50,30)
     assert senderBTC == (100 - 30) && receiverBTC == (50 + 30) && status == "Success"
    end

    test "Transaction Failure" do
     {senderBTC, receiverBTC, status} = MainServer.doTransactions(50,100,60)
     assert senderBTC == 50 && receiverBTC == 100 && status == "Failure"
    end
  end
end

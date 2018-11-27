defmodule Project1Test do
  use ExUnit.Case
  @message "This is a message"

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

  describe "generate" do
    test "should generate key pair with a public and private key" do
      assert {key_public, key_private} = KeyPair.generate()
      assert is_binary(key_public)
      assert is_binary(key_private)
    end
  end

  describe "to_public_key" do
    test "should not convert a private key to a public key" do
      {key_public, _key_private} = KeyPair.generate()
      {_key_public, key_private} = KeyPair.generate()
      refute key_public == KeyPair.to_public_key(key_private)
    end

    test "should convert a private key to a public key" do
      {key_public, key_private} = KeyPair.generate()
      assert key_public == KeyPair.to_public_key(key_private)
    end

    test "should convert an encoded key to a public key" do
      {key_public, key_private} = KeyPair.generate()
      assert key_public == key_private |> Base.encode16() |> KeyPair.to_public_key()
    end

    test "should convert a string key to a public key" do
      assert "0450863AD64A87AE8A2FE83C1AF1A8403CB53F53E486D8511DAD8A04887E5B23522CD470243453A299FA9E77237716103ABC11A1DF38855ED6F2EE187E9C582BA6" ==
               "18E14A7B6A307F426A94F8114701E7C8E774E7F9A47E2C2035DB29A206321725"
               |> KeyPair.to_public_key()
               |> Base.encode16()
    end
end

describe "Signature Correctness" do

  test "should generate and verify the given message" do
    {key_public, key_private} = KeyPair.generate()
    signature = Signature.generate(key_private, @message)
    assert is_binary(signature)
    assert true = Signature.verify(key_public, signature, @message)
  end

  test "should not verify an invalid message" do
    {key_public, key_private} = KeyPair.generate()
    signature = Signature.generate(key_private, @message)
    refute Signature.verify(key_public, signature, "message")
  end

  test "should not verify with an invalid private key" do
    {key_public, _key_private} = KeyPair.generate()
    signature = Signature.generate("key_private", @message)
    refute Signature.verify(key_public, signature, @message)
  end

  test "should not verify with an invalid public key" do
    {_key_public, key_private} = KeyPair.generate()
    signature = Signature.generate(key_private, @message)
    refute Signature.verify("key_public", signature, @message)
  end
 end
end

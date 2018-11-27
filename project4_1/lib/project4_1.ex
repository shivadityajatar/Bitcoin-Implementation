defmodule Server do
  use GenServer

  #This starts the GenServer
  def start_link(k) do
    GenServer.start_link(__MODULE__, k, name: :gens)
  end

  #GenServer initiated with k, i.e. the total number of zeros
  def init(k) do
    {:ok, k}
  end

  #This mines the bitcoins for the server
  def spawnThreadsServer(count, totalSpawn, zeroes, k, coinCount) do
    if count === totalSpawn do
      IO.puts "Maximum number of threads reached!"
      coinCount
    else
      random_str = "bitcoin;ayushiva" <> RandomizeStrings.randomizer(10)
      spawn(Hashing, :bitcoinHasher, [random_str, 0, zeroes, k,coinCount, self()]) #spawns new process to mine bitcoins
      coinsMined = receive do
        {coinCounter} ->
        coinCounter
      end
      spawnThreadsServer(count+1, totalSpawn, zeroes, k,coinsMined)
    end
  end
end


#This module has the main function and checks if k is a number or an IP address.
#Execution is carried out accordingly."
defmodule MainServer do
  def main(args) do
    args |> parse_args
  end

  defp parse_args([]) do
    IO.puts "No arguments given. Enter the value of k again"
  end

  defp parse_args(args) do
    {_, [k], _} = OptionParser.parse(args, strict: [limit: :integer])
    #K is a numeric value, so the main server is mining bitcoins on his server
    Server.start_link(k) #Starts the GenServer
    zeroes = String.duplicate("0", String.to_integer(k)) # gets the user input
    totalCoins = Server.spawnThreadsServer(0, 100, zeroes, k,0) # gets the total coins mined by server
    IO.puts "Total Bitcoins Mined: #{totalCoins}"
    IO.puts ""
    IO.puts "*******************************************************************************************************"
    IO.puts "----------------------------------------Transactions Information---------------------------------------"
    IO.puts "*******************************************************************************************************"
    IO.puts ""
    IO.puts "Transaction id | Sender Addr. | Receiver Addr. |           Time            |     Status      | Amount"
    totalUsers = Enum.random(5..10) #gets random number of users for transactions
    #creates wallets for all the users
    userWallets = Tuple.to_list(makeWallet(0,totalUsers,{},totalCoins,Kernel.trunc(totalCoins / (totalUsers+1)),Kernel.trunc(totalCoins / totalUsers)))
    totalTrans = Enum.random(5..10) #get random of transactions to be performed
    blocksInChain = makeBlockchain(totalUsers, 0,userWallets,{},totalTrans) #makes blocks for the transactions
    #performs the created transactions and returns updated wallet
    {updatedTrans,updatedWallet} = doTransactions(Tuple.to_list(blocksInChain),userWallets,totalTrans,0,DateTime.utc_now())
    IO.puts ""
    IO.puts "*******************************************************************************************************"
    IO.puts "------------------------------------------------WALLETS------------------------------------------------"
    IO.puts "*******************************************************************************************************"
    IO.puts "----------------------------------"
    printWallet(userWallets,length(userWallets),0,updatedTrans,updatedWallet) #prints final wallets
  end

  #creates wallet for each user with pul=blic & private key, with their initial balance
  def makeWallet(count, totalUsers, tuple,coins,lowerLimit,upperLimit) do
    if count <= totalUsers do
      {public_key, private_key} = KeyPair.keyPairMain()
      if totalUsers == count do
        userData = {coins, public_key, private_key}
        tuple1 = Tuple.append(tuple, Tuple.to_list(userData))
        makeWallet(count+1, totalUsers, tuple1,coins,lowerLimit,upperLimit)
      else
        assignedCoins = Enum.random(lowerLimit..upperLimit)
        userData = {assignedCoins, public_key, private_key}
        tuple1 = Tuple.append(tuple, Tuple.to_list(userData))
        makeWallet(count+1, totalUsers, tuple1,coins - assignedCoins,lowerLimit,upperLimit)
      end
    else
      tuple
    end
  end

  #makes a blockchain of transactions, with Receiver & Sender, with transaction ID & amount
  def makeBlockchain(totalUsers, count,walletsList,blocksInChain,totalTrans) do
    if(count<totalTrans) do
      {user1,user2} = validateBlock(totalUsers)
      amountReduced = Enum.random(1..(Enum.at(Enum.at(walletsList,user1),0) + 3))
      public_key_usr1 = Enum.at(Enum.at(walletsList,user1),1)
      public_key_usr2 = Enum.at(Enum.at(walletsList,user2),1)
      transactionID = RandomizeStrings.randomizer(8)
      status = "nil"
      transactionData = {public_key_usr1,public_key_usr2,amountReduced,transactionID,status}
      tuple1 = Tuple.append(blocksInChain, Tuple.to_list(transactionData))
      makeBlockchain(totalUsers, count+1,walletsList,tuple1,totalTrans)
    else
      blocksInChain
    end
  end

  #performs the actual transactions specified by blocks
  def doTransactions(blocksInChain,walletsList,totalTrans,count,currentTimeStamp) do
    if(count < totalTrans) do
      user1 = Enum.find_index(walletsList, fn x ->
        Enum.at(x,1) == Enum.at(Enum.at(blocksInChain,count),0)
      end)
      user2 = Enum.find_index(walletsList, fn x ->
        Enum.at(x,1) == Enum.at(Enum.at(blocksInChain,count),1)
      end)
      amountReduced = Enum.at(Enum.at(blocksInChain,count),2)
      newAmount1 = Enum.at(Enum.at(walletsList,user1),0) - amountReduced
      if(newAmount1 < 0) do
        IO.puts "   #{String.slice(Enum.at(Enum.at(blocksInChain,count),3),0,8)}         #{String.slice(Enum.at(Enum.at(walletsList,user1),1),0,6)}         #{String.slice(Enum.at(Enum.at(walletsList,user2),1),0,6)}       #{to_string(currentTimeStamp)}    Unconfirmed     #{amountReduced} BTC"
        updatedTrans = List.replace_at(blocksInChain, count, List.replace_at(Enum.at(blocksInChain,count),4,"Failure"))
        Process.sleep(500)
        doTransactions(updatedTrans,walletsList,totalTrans,count+1,DateTime.utc_now())
      else
        private_key = Enum.at(Enum.at(walletsList,user1),2)
        block_msg = Enum.at(Enum.at(walletsList,user1),1)
        signature = Signature.generate(private_key,block_msg)
        if signature do
          
        end
        updatedList = List.replace_at(walletsList,user1,List.replace_at(Enum.at(walletsList,user1), 0, newAmount1))
        newAmount2 = Enum.at(Enum.at(walletsList,user2),0) + amountReduced
        updatedList2 = List.replace_at(updatedList,user2,List.replace_at(Enum.at(updatedList,user2), 0, newAmount2))
        IO.puts "   #{String.slice(Enum.at(Enum.at(blocksInChain,count),3),0,8)}         #{String.slice(Enum.at(Enum.at(walletsList,user1),1),0,6)}         #{String.slice(Enum.at(Enum.at(walletsList,user2),1),0,6)}       #{to_string(currentTimeStamp)}      Success       #{amountReduced} BTC"
        updatedTrans = List.replace_at(blocksInChain, count, List.replace_at(Enum.at(blocksInChain,count),4,"Success"))
        Process.sleep(500)
        doTransactions(updatedTrans,updatedList2,totalTrans,count+1,DateTime.utc_now())
      end
    else
      {blocksInChain,walletsList}
    end
  end

  #prints the wallets for users finally
  def printWallet(walletsList,totalUsers,count,blocksInChain,updatedWallet) do
    if(count<totalUsers) do
      IO.puts "Wallet: #{String.slice(Enum.at(Enum.at(walletsList,count),1), 0, 6)}"
      printUserTrans(Enum.at(Enum.at(walletsList,count),1),blocksInChain,1)
      IO.puts "---------"
      IO.puts "Balance: #{Enum.at(Enum.at(updatedWallet,count),0)} BTC"
      IO.puts "**********************************"
      printWallet(walletsList,totalUsers,count+1,blocksInChain,updatedWallet)
    end
  end

  #prints each transaction for user
  def printUserTrans(user_public_key, blocksInChain,count) do
    trans = Enum.find_index(blocksInChain, fn x ->
      Enum.at(x,0) == user_public_key
    end)
    if trans != nil do
      if(Enum.at(Enum.at(blocksInChain,trans),4) == "Success") do
        if(count == 1) do
          IO.puts "Transaction:#{count}"
        else
          IO.puts "---------"
          IO.puts "Transaction:#{count}"
        end
        IO.puts "Receiver: #{String.slice(Enum.at(Enum.at(blocksInChain,trans),1),0,6)}"
        IO.puts "Amount: #{Enum.at(Enum.at(blocksInChain,trans),2)}"
        IO.puts "Status: #{Enum.at(Enum.at(blocksInChain,trans),4)}"
        updatedTrans = List.delete_at(blocksInChain, trans)
        printUserTrans(user_public_key, updatedTrans,count+1)
      else
        updatedTrans = List.delete_at(blocksInChain, trans)
        printUserTrans(user_public_key, updatedTrans,count)
      end
    else
      if(count == 1) do
        IO.puts "No transactions for this wallet"
      end
    end
  end

  def doTransactions(senderBalance,receiveBalance,amountReduced) do
    updatedSenderBitcoins = senderBalance-amountReduced
    updatedReceiverBitcoins = receiveBalance+amountReduced
    if(updatedSenderBitcoins < 0) do
      {senderBalance,receiveBalance,"Failure"}
    else
      {updatedSenderBitcoins,updatedReceiverBitcoins,"Success"}
    end
  end

  def validateBlock(totalUsers) do
    user1 = Enum.random(0..totalUsers-1)
    user2 = Enum.random(0..totalUsers-1)
    if (user1 == user2) do
      validateBlock(totalUsers)
    else
      {user1,user2}
    end
  end

end

defmodule Hashing do
  #mines coins by finding a string with specified number of zeroes in front
  def bitcoinHasher(random_str, counter, zeroes, k,coinCount, pid) do
     final_str = random_str <> Integer.to_string(counter)
     hash = String.downcase(:crypto.hash(:sha256, final_str )|> Base.encode16)
     if String.starts_with?(hash,zeroes) do
       bitcoin = final_str <> "\t" <> hash
       IO.puts bitcoin
       if counter < 45978 do
         bitcoinHasher(random_str, counter+1, zeroes, k,coinCount+1, pid)
       else
         send pid , {coinCount}
       end
     else
       if counter < 45978 do
         bitcoinHasher(random_str, counter+1, zeroes, k,coinCount, pid)
       else
         send pid , {coinCount}
       end
     end
   end

  def bitcoinHasher(random_str) do
    :crypto.hash(:sha256, random_str )|> Base.encode16
  end

end
#Module for creating random strings from alphabets and digits for distribution of work to the workers from the servers so that the random string can never be the same and then we append the integer values
defmodule RandomizeStrings do
   def randomizer(length, type \\ :all) do
     alphabets = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
     numbers = "0123456789"
      lists =
       cond do
         type == :alpha -> alphabets <> String.downcase(alphabets)
         type == :numeric -> numbers
         type == :upcase -> alphabets
         type == :downcase -> String.downcase(alphabets)
         true -> alphabets <> String.downcase(alphabets) <> numbers
       end
       |> String.split("", trim: true)
     do_randomizer(length, lists)
   end

  defp get_range(length) when length > 1, do: (1..length)
  defp get_range(length), do: [1]

  defp do_randomizer(length, lists) do
     get_range(length)
     |> Enum.reduce([], fn(_, acc) -> [Enum.random(lists) | acc] end)
     |> Enum.join("")
  end
 end

 defmodule KeyPair do

   @type_algorithm :ecdh
   @ecdsa_curve :secp256k1

   def generate, do: :crypto.generate_key(@type_algorithm, @ecdsa_curve)

   def to_public_key(private_key) do
     private_key
     |> String.valid?()
     |> maybe_decode(private_key)
     |> generate_key()
   end

   defp maybe_decode(true, private_key), do: Base.decode16!(private_key)
   defp maybe_decode(false, private_key), do: private_key

   defp generate_key(private_key) do
     with {public_key, _private_key} <-
            :crypto.generate_key(@type_algorithm, @ecdsa_curve, private_key),
          do: public_key
   end

   def keyPairMain() do
       {public_key1, private_key1} = KeyPair.generate()
       public_key = public_key1 |> Base.encode16
       private_key = private_key1 |> Base.encode16
       {public_key, private_key}
   end

 end

defmodule Signature do
  @ecdsa_curve :secp256k1
  @type_signature :ecdsa
  @type_hash :sha256

  @spec generate(binary, String.t()) :: String.t()
  def generate(private_key, message),
   do: :crypto.sign(@type_signature, @type_hash, message, [private_key, @ecdsa_curve])

  @spec verify(binary, binary, String.t()) :: boolean
  def verify(public_key, signature, message) do
   :crypto.verify(@type_signature, @type_hash, message, signature, [public_key, @ecdsa_curve])
  end
end

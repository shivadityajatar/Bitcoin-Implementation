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

  #Called for the worker, when it asks for the required number of leading zeroes
  def handle_call(:msg, _from, zeroes) do
    {:reply, zeroes, zeroes}
  end

  #Called for the worker ,when it asks for a random string to mine bitcoins
  def handle_call(:get_str, _from, zeroes) do
      str = "bitcoin;ayushiva" <> RandomizeStrings.randomizer(10)
      {:reply, str, zeroes}
  end

  #Called for the worker ,when it sends back the mined bitcoin
  def handle_cast({:send_hash, hash}, state) do
    IO.inspect ["client",hash]
    {:noreply, state}
  end

  #Called for the worker ,when it sends back the number of mined bitcoins
  def handle_cast({:send_total_coins, coins,pid}, state) do
    pid1 = Kernel.inspect(pid)
    len = String.length(pid1)
    str1 = String.slice(pid1, len-6, len-1)
    str2 = "<0" <> str1
    ans = :erlang.list_to_pid('#{str2}')
    send ans, coins
    {:noreply, state}
  end

  #This function is called when the worker on the server mines bitcoins
  def spawnThreadsServer(count, totalSpawn, zeroes, server_ip, k, coinCount) do
    if count === totalSpawn do
      IO.puts "Maximum number of threads reached!"
      coinCount
    else
      random_str = "bitcoin;ayushiva" <> RandomizeStrings.randomizer(10)
      spawn(Hashing, :bitcoinHasher, [random_str, 0, zeroes, server_ip, k,coinCount, self()])
      coinsMined = receive do
        {coinCounter} ->
        coinCounter
      end
      spawnThreadsServer(count+1, totalSpawn, zeroes, server_ip, k,coinsMined)
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
     if String.match?(k, ~r/[\d]+\.[\d]+\.[\d]+\.[\d]+/) do
        #If it's an IP address, the worker asks for work from the Server and mines bitcoins.
        server_ip = String.to_atom("serv@" <> k)
        server_ip1 = String.to_atom("serv1@" <> k)
        #starts the worker with server_ip, so its can send the mined coins
        Worker.initialize_worker(server_ip,server_ip1)
        Worker.get_zeroes(server_ip, k,self())
      else
        #If k is a numeric value, then the main server is mining bitcoins on his server
        server_ip = String.to_atom("serv@"<>findIP())
        Node.start(server_ip) # starts the node with the IP found using findIP
        Node.set_cookie(server_ip,:chocolate)
        Server.start_link(k) #starts the GenServer
        zeroes = String.duplicate("0", String.to_integer(k)) #get the zeroes specified by user
        serverCoins = Server.spawnThreadsServer(0, 100, zeroes, server_ip, k,0)  # gets the total coins mined by server
        IO.puts "Total Bitcoins mined by Server: #{serverCoins}"
        coinsClient = receive do # gets the total coins mined by client
          coinVal ->
          coinVal
        end
        IO.puts "Total Bitcoinscoins mined by Worker: #{coinsClient}"
        totalCoins = coinsClient + serverCoins # gets the total coins mined by server & client
        IO.puts "Total Bitcoins Mined: #{totalCoins}"
        IO.puts ""
        IO.puts "*******************************************************************************************************"
        IO.puts "----------------------------------------Transactions Information---------------------------------------"
        IO.puts "*******************************************************************************************************"
        IO.puts ""
        IO.puts "Transaction id | Sender Addr. | Receiver Addr. |           Time            |     Status      | Amount"
        totalUsers = Enum.random(5..10)
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

  #creates a block and send for validation, with Receiver & Sender, with transaction ID & amount
  def makeBlockchain(totalUsers, count,walletsList,blocksInChain,totalTrans) do
    if(count<totalTrans) do
      {user1,user2} = validateBlocks(totalUsers)
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
        if(signature) do
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
      printWallet(walletsList, totalUsers,count+1,blocksInChain,updatedWallet)
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

  def validateBlocks(totalUsers) do
    user1 = Enum.random(0..totalUsers-1)
    user2 = Enum.random(0..totalUsers-1)
    if (user1 == user2) do
      validateBlocks(totalUsers)
    else
      {user1,user2}
    end
  end

  #This function finds the server's IP address to make a connection"
  def findIP() do
    {ops_sys, versionof } = :os.type
    ip =
    case ops_sys do
     :unix ->
        case versionof do
          :darwin -> {:ok, [addr: ip]} = :inet.ifget('en0', [:addr])
          to_string(:inet.ntoa(ip))
          :linux ->  {:ok, [addr: ip]} = :inet.ifget('ens3', [:addr])
          to_string(:inet.ntoa(ip))
        end
      :win32 -> {:ok, [ip, _]} = :inet.getiflist
        to_string(ip)
    end
      (ip)
  end
end

#This is the Worker module which consists of the functions of the worker
defmodule Worker do
  #The worker is initialized, cookie is set for connection and then it is connected to the server"
  def initialize_worker(server_ip,server_ip1) do
    Node.start(server_ip1)
    Node.set_cookie(server_ip1,:chocolate)
    connection = Node.connect(server_ip)
    if Atom.to_string(connection) === "true" do
      IO.puts "Connected to the master successfully!"
    else
      raise "Connection failed!"
    end
  end

  #The worker calls the GenServer to get 'k' which is the required number of leading zeroes
  def get_zeroes(server_ip, k,pid) do
    number_zeroes = GenServer.call({:gens, server_ip}, :msg)
    zeroes = String.duplicate("0",String.to_integer(number_zeroes))
    mine_bitcoin(zeroes, server_ip, k,pid)
  end

  #The worker calls the function to spawn threads
  def mine_bitcoin(zeroes, server_ip, k,pid) do
    try do
      totalCoins = Worker.spawnThreadsClient(0, 50, zeroes, server_ip, k,0)
      IO.puts "Bitcoins mined by Worker: #{totalCoins}"
      GenServer.cast({:gens, server_ip}, {:send_total_coins, totalCoins,pid})
    catch
      :exit,_ -> IO.puts "Server died!"; exit(:shutdown)
    end
  end

  #The worker spawns threads and calls the function to mine bitcoins
  def spawnThreadsClient(count, totalSpawn, zeroes, server_ip, k, coinCount) do
    if count === totalSpawn do
      IO.puts "Maximum number of threads reached!"
      coinCount
    else
      random_str = GenServer.call({:gens,server_ip}, :get_str)
      spawn(Hashing,:bitcoinHasher, [random_str, 0, zeroes, server_ip, k,coinCount, self()])
      coinsMined = receive do
        {coinCounter} ->
        coinCounter
      end
      spawnThreadsClient(count+1, totalSpawn, zeroes, server_ip, k,coinsMined)
      end
  end

  #The worker sends the mined bitcoin to the GenServer
  def send_hash(:gens, hash, server_ip) do
    GenServer.cast({:gens, server_ip}, {:send_hash, hash})
  end
end

#This module contains our hashing function to mine bitcoins.
#The worker then sends the hash to the handle_cast, which gives it to server.
 defmodule Hashing do
  def bitcoinHasher(random_str, counter, zeroes, server_ip, k,coinCount, pid) do
   final_str = random_str <> Integer.to_string(counter)
   hash = String.downcase(:crypto.hash(:sha256, final_str )|> Base.encode16)
   if String.starts_with?(hash,zeroes) do
     bitcoin = final_str <> "\t" <> hash
     if String.match?(k, ~r/[\d]+\.[\d]+\.[\d]+\.[\d]+/) do
       IO.puts bitcoin
       Worker.send_hash(:gens,bitcoin,server_ip)
     else
       IO.puts bitcoin
     end
     if counter < 45978 do
       bitcoinHasher(random_str, counter+1, zeroes,server_ip, k,coinCount+1, pid)
     else
       send pid , {coinCount}
     end
   else
     if counter < 45978 do
       bitcoinHasher(random_str, counter+1, zeroes,server_ip, k,coinCount, pid)
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

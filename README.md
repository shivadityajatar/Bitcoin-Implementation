# Bitcoin Implementation
COP5615 - Distributed Operating Systems Principles - Project 4.1

The goal of this part of project is to implement enough of Bitcoin protocol to be able to mine bitcoins, implement wallets, transact bitcoins and write test cases verifying the correctness for each task. (Specifically, for correct computation of the hashes, for transaction between two participants)

## Group Information

* **Shivaditya Jatar** - *UF ID: 6203 9241* 
* **Ayush Mittal** - *UF ID: 3777 8171* 

#### Important Note: - Before running the program you need to run the 'epmd -daemon' command on the terminal so that the the epmd daemon is detached. The epmd daemon is the Erlang Port Mapper Daemon.

## Contents of this file

Functionalities Implemented, Prerequisites, Instruction Section, Testing

## Functionalities Implemented

#### 1. Mining

In our project, First the server runs by mining the bitcoins which match the same number of leading zeroes as 'k'. Bitcoins are mined by performing a SHA-256 of a random string which has been appended to **"bitcoin;ayushiva"**.  In our project bitcoins are mined by using the 'HashCash Algorithm' as a **proof of work**. A counter is appended to the randomized string and the resulting string is hashed. If the hash has 'k' leading zeroes, then this is a valid bitcoin. Otherwise, the counter is incremented by one. This counter is initialized to 0 and it keeps getting incremented every time until a bitcoin with 'k' leading zeroes is mined. As the bitcoin is mined, then it gets printed.

#### 2. Implement Wallets

Wallet contains **ECDSA** keypairs. A keypair consists of a "public key" and a "private key" which can be used to encrypt or sign bits of data. The public key, is known to everyone and can be used to encrypt messages in such a way that the holder of the private key alone may decrypt them. The private key may also be used to sign messages in such a way that anyone holding the public key may verify that the message truly came from you. Every Bitcoin address consists of such a keypair - the "address" we send to people is the public half and the private half resides in your wallet.
Along with this, Wallet keeps the amount of Bitcoins (BTC) available.
(For this part, we are taking random number of participants and hence the wallets)

#### 3. Transact Bitcoins

When we send Bitcoin, a Bitcoin transaction (with transaction ID), is created by your wallet client and then broadcast to the network. Bitcoin nodes on the network will relay and rebroadcast the transaction, and if the transaction is valid, nodes will include it in the block they are mining. The transaction will be included, along with other transactions, in a block in the blockchain. At this point the receiver is able to see the transaction amount in their wallet.
(For this part, we are performing random number of transactions)

## Prerequisites

#### Erlang OTP 21(10.0.1)
#### Elixir version 1.7.3

## Instruction section

**Note: For mining bitcoins, very fast (milliseconds to seconds) you should provide No. of leading zeroes in bitcoin <= 4.**

#### To run the App

```elixir
(Before running, Goto project4_1 directory, where mix.exs is present)
$ cd project4_1
$ mix escript.build
$ escript project4_1 <No. of Leading zeroes in bitcoin>

e.g. escript project4_1 4

SAMPLE O/P->

bitcoin;ayushivaJMXqRtEOBG40726 0000abcbb0457038f098d6e152fe1c8df6c4b0d8217fd4d6fa76bfef19daeb56
bitcoin;ayushivaDPI32yheLA9838  0000b73d2dc3a19143f19e3e48f0db3b4170ade34903464296a06b110efd2fc1
bitcoin;ayushivad7Af7w0EOf33902 00003659fa20d741934d5351322741612e83a038ca91c7302e58a90225d7332a
bitcoin;ayushivad7Af7w0EOf45950 0000c2ab11ca533a5d17dd9d3156414aa4a654f8f55bfea7b7c5be340e50e51a
bitcoin;ayushivaD2DQP6AmOy27792 000018159882666a92e00a54390ee6bd5e49df483b045ed494e51aeb668bbf2a
bitcoin;ayushivaD2DQP6AmOy29990 0000b1c2db8c133beafa9827bb71f856236e87dbef7360a500e68871b1b7281b
bitcoin;ayushivaD2DQP6AmOy39848 00003ca3918faa5e6f545b5fe803227c9c4a6b0493bba92b26c3e9b43013a85e
bitcoin;ayushiva0WiIhqy0I211816 000032cfc625271c242ca44a74a2668d0c603e8fc4773b993d4534beaafc5718
bitcoin;ayushivaTBBNjm2Wpf31975 0000f401250245d9abfccb86a8cdeb0851e43b0dbc4d05cee75f289861d9fff6
bitcoin;ayushivaF3dngFiCNt18821 000031166bf33dd2b02e9f0e06843160884baf9919300cbfc12198e45c123ebc
bitcoin;ayushiva1utinAIoNW4835  00001bde14045f40c652312a7494e683d232ee0470b900c7f473a2adfad73a0f
bitcoin;ayushiva1utinAIoNW7076  00003ab635f837b13ded018725f46c516ab3da920b0f7ef25b07ac4bed018bcf
bitcoin;ayushiva1utinAIoNW20043 00001d64d4493ef32a67f2e872fc3e0b96226440cfd4ad71eb5f15122ad7f47a
bitcoin;ayushivaTCMCCcxfRu11118 00006fb3fffdea863ce1fc2f6e4ff72c14528b252e213604ff2722c695cbda58
bitcoin;ayushivayXkoyLxpxB2502  0000b2873c06796864de0cb349f2e1d9ba439be2f87d5843e0be04dda6a3972d
..
..
Maximum number of threads reached!
Total Bitcoins mined = 91

*******************************************************************************************************
-------------------------------------------Transactions Info-------------------------------------------
*******************************************************************************************************

Transaction id | Sender Addr. | Receiver Addr. |           Time            |     Status      | Amount

   MRuuLnxD         04EBAE         0408A4       2018-11-25 05:53:49.306000Z      Success       4 BTC

   h8aRhzOJ         04F9F3         04EBAE       2018-11-25 05:53:49.313000Z      Success       3 BTC

   VO6RFu1s         041987         0495C0       2018-11-25 05:53:49.316000Z      Success       5 BTC

   SkFoAfye         0483EC         0442D6       2018-11-25 05:53:49.318000Z    Unconfirmed     9 BTC

   OS6W9B3n         0483EC         0495C0       2018-11-25 05:53:49.319000Z    Unconfirmed     10 BTC

   89OYxdCB         0483EC         04EBAE       2018-11-25 05:53:49.320000Z    Unconfirmed     10 BTC
   ..
   ..

*******************************************************************************************************
------------------------------------------------WALLETS------------------------------------------------
*******************************************************************************************************
----------------------------------
Wallet: 046788
Transaction:1
Receiver: 046D61
Amount: 2
Status: Success
---------
Balance: 26 BTC
**********************************
Wallet: 04573A
Transaction:1
Receiver: 046788
Amount: 8
Status: Success
---------
Balance: 2 BTC
**********************************
Wallet: 049F81
No transactions for this wallet
---------
Balance: 9 BTC
**********************************
Wallet: 04A1D4
Transaction:1
Receiver: 046788
Amount: 8
Status: Success
---------
Balance: 1 BTC
**********************************
Wallet: 0451FA
Transaction:1
Receiver: 046D61
Amount: 4
Status: Success
---------
Transaction:2
Receiver: 046788
Amount: 2
Status: Success
---------
Balance: 5 BTC
**********************************
Wallet: 046D61
No transactions for this wallet
---------
Balance: 16 BTC
**********************************
Wallet: 043905
Transaction:1
Receiver: 0451FA
Amount: 1
Status: Success
---------
Balance: 8 BTC
**********************************
Wallet: 04C14A
No transactions for this wallet
---------
Balance: 8 BTC
**********************************
```
Starts the app, passing in No. of Leading zeroes in bitcoin. The console prints the bitcoins and the transactions performed along with wallets of participants.

#### To run the App (Bonus Part)

**1. Keep the System connected to network (LAN)**

**2. Before running the worker with the IP address of the server, we have to run the Server by giving the numeric k value first (i.e the number of leading zeroes) and then run the worker. Otherwise the worker will not be able to connect to the Server.**

**On Server Side**

```elixir
(Before running, Goto project4_1bonus directory, where mix.exs is present)
$ cd project4_1bonus
$ mix escript.build
$ escript project4_1bonus <No. of Leading zeroes in bitcoin>
e.g. escript project4_1bonus 4
```
Starts the app, passing in No. of Leading zeroes in bitcoin. The console prints the bitcoins and the transactions performed along with wallets of participants.

**On Worker Side**
```elixir
(Before running, Goto project4_1bonus directory, where mix.exs is present)
$ cd project4_1bonus
$ mix escript.build
$ escript project4_1bonus <IP address of Server>
e.g. escript project4_1bonus 192.168.0.2
```
Starts the app, passing in IP address of the Server. The console prints the bitcoins mined.

### FOR SAMPLE OUTPUT, REFER TO Report-Bonus.pdf.

## Testing

We have written test cases verifying the correctness for multiple tasks.

1. For correct computation of the hashes: This will test for correctness of hashing (SHA-256) used in bitcoin mining.

2. Functional test for correctness of transaction: This will test for correctness of transaction between two participants. For correct bitcoin amount (in BTC) transaction and for status of transaction (success/failure)

```elixir
(Before running, Goto project4_1 directory, where mix.exs is present)
$ cd project4_1
$ mix escript.build
$ mix test
e.g. mix test

SAMPLE O/P->
...

Finished in 0.09 seconds
3 tests, 0 failures

Randomized with seed 841000

```


### Testing Bonus Part

**We have written two extra tests:**

3. For correct evaluation of Key-Pair (public-private key pair): This will test for correct evaluation of public-private key pair generation. It will also test by converting private key to public key using a function and comparing it with calculated public key.

4. For correctness of Signature: This will test for correctness of signature. It will verify the signature using public key.

#### To run the Test (Bonus Part)

```elixir
(Before running, Goto project4_1bonus directory, where mix.exs is present)
$ cd project4_1bonus
$ mix escript.build
$ mix test
e.g. mix test

SAMPLE O/P->
...

Finished in 0.5 seconds
12 tests, 0 failures

Randomized with seed 202000

```
## For Complete (Detailed) Output, refer to Report.pdf and Report-Bonus.pdf.

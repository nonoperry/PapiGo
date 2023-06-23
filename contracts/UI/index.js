window.addEventListener("load", async () => {
  // Check if Web3 is injected by the browser
  if (typeof web3 !== "undefined") {
    web3 = new Web3(web3.currentProvider);
  } else {
    // Set the provider you want from Web3.providers
    web3 = new Web3(new Web3.providers.HttpProvider("http://127.0.0.1:7545"));
  }

  // Set the deployed contract address and ABI
  const contractAddress = "<CONTRACT_ADDRESS>";
  const contractABI = <CONTRACT_ABI>;

  const paymentSystem = new web3.eth.Contract(contractABI, contractAddress);

  // Get the account addresses
  const accounts = await web3.eth.getAccounts();
  const account = accounts[0];

  // Update balance display
  const updateBalance = async () => {
    const balance = await paymentSystem.methods.balances(account).call();
    document.getElementById("balance").innerText = `Balance: ${balance} ETH`;
  };

  updateBalance();

  // Handle deposit form submission
  document.getElementById("depositForm").addEventListener("submit", async (e) => {
    e.preventDefault();
    const amount = document.getElementById("depositAmount").value;

    await paymentSystem.methods.deposit().send({ from: account, value: web3.utils.toWei(amount, "ether") });
    updateBalance();
  });

  // Handle withdraw form submission
  document.getElementById("withdrawForm").addEventListener("submit", async (e) => {
    e.preventDefault();
    const amount = document.getElementById("withdrawAmount").value;

    await paymentSystem.methods.withdraw(web3.utils.toWei(amount, "ether")).send({ from: account });
    updateBalance();
  });
});

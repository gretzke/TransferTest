const token = artifacts.require('fa1_2');
const test = artifacts.require('test');
const { MichelsonMap } = require('@taquito/taquito');
const { alice, bob } = require('./helpers/accounts');

const initial_storage_token = {
  ledger: MichelsonMap.fromLiteral({
    [alice.pkh]: {
      balance: 10000000000,
      allowances: MichelsonMap.fromLiteral({}),
    },
  }),
  total_supply: 10000000000,
};

const initial_storage_test = (token_address) => {
  return {
    owner: alice.pkh,
    token_address: token_address,
    balance_response: 0,
  };
};

contract('token', (_accounts) => {
  let tokenInstance;
  let instance;

  before(async () => {
    tokenInstance = await token.new(initial_storage_token);
    instance = await test.new(initial_storage_test(tokenInstance.address));
    await tokenInstance.approve(instance.address, 100000);
  });

  it('stored token address should match actual address', async () => {
    const storage = await instance.storage();
    assert.equal(storage.token_address, tokenInstance.address);
  });

  it('should be able to transfer tokens', async () => {
    await tokenInstance.transfer(alice.pkh, bob.pkh, 10);
    const storage = await tokenInstance.storage();
    const account_bob = await storage.ledger.get(bob.pkh);
    assert.equal(account_bob.balance, 10);
  });

  it('this does not fail apparently', async () => {
    await instance.test(bob.pkh, 10);
    const storage = await tokenInstance.storage();
    const account_bob = await storage.ledger.get(bob.pkh);
    assert.equal(account_bob.balance, 20);
  });
});

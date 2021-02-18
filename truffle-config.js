const { alice } = require('./test/helpers/accounts');

module.exports = {
  // see <http://truffleframework.com/docs/advanced/configuration>
  // for more details on how to specify configuration options!
  contracts_directory: './contracts/main',
  networks: {
    development: {
      host: 'http://localhost',
      port: 8732,
      network_id: '*',
      secretKey: alice.sk,
      type: 'tezos',
    },
  },
};

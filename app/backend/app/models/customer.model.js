module.exports = (sequelize, Sequelize) => {
  const Customer = sequelize.define('customer', {
    id: {
      type: Sequelize.INTEGER,
      primaryKey: true,
      autoIncrement: true
    },
    firstname: {
      type: Sequelize.STRING,
      allowNull: false
    },
    lastname: {
      type: Sequelize.STRING,
      allowNull: false
    },
    age: {
      type: Sequelize.INTEGER
    },
    address: {
      type: Sequelize.STRING
    }
  }, {
    timestamps: true
  });

  return Customer;
};

const db = require('../models');
const Customer = db.customers;

// Create customer
exports.create = async (req, res) => {
  try {
    const { firstname, lastname, age, address } = req.body;

    if (!firstname || !lastname) {
      return res.status(400).send({
        message: 'Firstname and Lastname are required!'
      });
    }

    const customer = await Customer.create({
      firstname,
      lastname,
      age,
      address
    });

    res.status(201).send(customer);
  } catch (error) {
    res.status(500).send({
      message: error.message || 'Error creating customer'
    });
  }
};

// Get all customers
exports.findAll = async (req, res) => {
  try {
    const customers = await Customer.findAll();
    res.send(customers);
  } catch (error) {
    res.status(500).send({
      message: error.message || 'Error retrieving customers'
    });
  }
};

// Get customer by ID
exports.findOne = async (req, res) => {
  try {
    const id = req.params.id;
    const customer = await Customer.findByPk(id);

    if (!customer) {
      return res.status(404).send({
        message: `Customer with id=${id} not found`
      });
    }

    res.send(customer);
  } catch (error) {
    res.status(500).send({
      message: `Error retrieving customer with id=${req.params.id}`
    });
  }
};

// Update customer
exports.update = async (req, res) => {
  try {
    const id = req.params.id;
    const updated = await Customer.update(req.body, {
      where: { id: id }
    });

    if (updated[0] === 1) {
      res.send({ message: 'Customer updated successfully' });
    } else {
      res.status(404).send({
        message: `Cannot update customer with id=${id}`
      });
    }
  } catch (error) {
    res.status(500).send({
      message: `Error updating customer with id=${req.params.id}`
    });
  }
};

// Delete customer
exports.delete = async (req, res) => {
  try {
    const id = req.params.id;
    const deleted = await Customer.destroy({
      where: { id: id }
    });

    if (deleted === 1) {
      res.send({ message: 'Customer deleted successfully' });
    } else {
      res.status(404).send({
        message: `Cannot delete customer with id=${id}`
      });
    }
  } catch (error) {
    res.status(500).send({
      message: `Error deleting customer with id=${req.params.id}`
    });
  }
};

// Delete all customers
exports.deleteAll = async (req, res) => {
  try {
    const deleted = await Customer.destroy({
      where: {},
      truncate: false
    });

    res.send({ message: `${deleted} customers deleted successfully` });
  } catch (error) {
    res.status(500).send({
      message: error.message || 'Error deleting all customers'
    });
  }
};

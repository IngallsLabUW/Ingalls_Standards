library(Rdisop)

formula_1 = "C3H7O5S"
electron_mass = 0.00054858

# Positive
x = getMass(getMolecule(formula_1)) - electron_mass
print(x, digits = 9)

# Negative
x = getMass(getMolecule(formula_1)) + electron_mass
print(x, digits = 9)
from FixedPoint import FXfamily, FXnum
fam100 = FXfamily(100)
z = FXnum(1, fam100)
z2 = fam100(2)
print('1 = ', z.toBinaryString(logBase=4))
print('log2 = ', fam100.log2)
print('sqrt2 = ', fam100.sqrt2)

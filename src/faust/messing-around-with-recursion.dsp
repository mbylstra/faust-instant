//smooth(s) = *(1.0 - s) : + ~ *(s);


//smooth = *(1.0 - 0.5) : + ~ *(0.5);


multHalf = _ * 0.5;
add = +;

//smooth = _ * 0.5 : add ~ multHalf : _ * 0.5; // holy moly, 3 operators in a row??? Really confused now.
smooth = _ * 0.5 : multHalf ~ add : _ * 0.5; // holy moly, 3 operators in a row??? Really confused now.


// I GET IT NOW!
// ~ combines two "processes", but one of them must have 2 inputs for it to work??

// The number of outputs of the first expression should be greater or equal to the number of inputs of the second expression.


process = smooth;

increasingInts = 1 : + ~ _;  // I still don't really get this though!!

increasingInts = 1 : _ ~ +;  // I still don't really get this though!! Wow, you can put them the other way around!

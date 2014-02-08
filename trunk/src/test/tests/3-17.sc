//@ main

// NOTE: this test will fail if binary is compiled with malloc arrays

function main()
{
    s = new_array(10000, 1);
    s[9] = 3;
    return s[9];
}


//@ main

function main()
{
    s = new_array(10, 0);
    s[9] = 3;
    s[8] = 0;
    s[7] = 1;
    return s[7] + s[8] + s[9];
}


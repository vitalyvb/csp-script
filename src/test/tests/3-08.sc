//@ main

function main()
{
    s = new_array(10, 1);
    s[-1] = 257;
    return s[-1];
}


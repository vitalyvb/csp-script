//@ main

global q,w,e;

map test {
    1=42,
    2=66,
    3=244,
    4=249,
    5=66,
    6=223,
    7=4,
    8=1,
}

map test2 {
    1=42,
    80=1,
}

function main()
{
    return _addx(1, 2, 4, 8, 16, 32, 64);
}


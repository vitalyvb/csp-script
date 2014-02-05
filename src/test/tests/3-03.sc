//@ main 8

global q,w,e;

map test {
    1=42,
    2=66,
    3=244,
    4=249,
    5=66,
    6=223,
    7=4,
    8=1
}

map test2 {
    1=42,
    80=1
}

function main(n)
{
    return _sub(_add(5, 10), -15);
}


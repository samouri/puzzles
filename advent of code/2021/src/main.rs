mod day1;
mod day2;
mod day3;

fn main() -> std::io::Result<()> {
    println!("Problem 1\n-----------");
    day1::solve().unwrap();

    println!("Problem 2\n-----------");
    day2::solve().unwrap();

    println!("Problem 3\n-----------");
    day3::solve()
}

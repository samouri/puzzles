mod day1;
mod day2;
mod day3;
mod day4;
mod day5;
mod day6;

fn main() -> std::io::Result<()> {
    println!("Problem 1\n-----------");
    day1::solve().unwrap();

    println!("Problem 2\n-----------");
    day2::solve().unwrap();

    println!("Problem 3\n-----------");
    day3::solve().unwrap();

    println!("Problem 4\n-----------");
    day4::solve().unwrap();

    println!("Problem 5\n-----------");
    day5::solve().unwrap();

    println!("Problem 6\n-----------");
    day6::solve()
}

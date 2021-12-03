mod day1;
mod day2;

fn main() -> std::io::Result<()> {
    println!("Problem 1\n-----------");
    day1::solve().unwrap();

    println!("Problem 2\n-----------");
    day2::solve()
}

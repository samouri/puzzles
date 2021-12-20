mod day1;
mod day10;
mod day11;
mod day12;
mod day13;
mod day14;
mod day15;
mod day2;
mod day3;
mod day4;
mod day5;
mod day6;
mod day7;
mod day9;

fn main() -> std::io::Result<()> {
    println!("Problem 1\n-----------");
    day1::solve();

    println!("Problem 2\n-----------");
    day2::solve().unwrap();

    println!("Problem 3\n-----------");
    day3::solve().unwrap();

    println!("Problem 4\n-----------");
    day4::solve().unwrap();

    println!("Problem 5\n-----------");
    day5::solve().unwrap();

    println!("Problem 6\n-----------");
    day6::solve().unwrap();

    println!("Problem 7\n-----------");
    day7::solve().unwrap();

    println!("Problem 9\n-----------");
    day9::solve();

    println!("Problem 10\n-----------");
    day10::solve();

    Ok(())

    // println!("Problem 11\n-----------");
    // day11::solve().unwrap();

    // println!("Problem 12\n-----------");
    // day12::solve().unwrap();

    // println!("Problem 13\n-----------");
    // day13::solve().unwrap();

    // println!("Problem 14\n-----------");
    // day14::solve().unwrap();
    // print!("\n");

    // println!("Problem 15\n-----------");
    // day15::solve()
}

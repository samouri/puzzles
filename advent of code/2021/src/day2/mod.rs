use std::fs;

pub fn solve() -> std::io::Result<()> {
    let path = "src/day2/input.txt";
    let contents = fs::read_to_string(path).expect("Something went wrong reading the file");
    let instructions: Vec<(&str, i32)> = contents
        .lines()
        .map(|l| l.split_at(l.find(" ").unwrap()))
        .map(|(dir, count)| (dir.trim(), count.trim().parse::<i32>().unwrap()))
        .collect();

    // Part 1
    let mut depth = 0;
    let mut horizontal = 0;
    for (dir, count) in &instructions {
        if dir == &"down" {
            depth += count
        } else if dir == &"up" {
            depth -= count
        } else if dir == &"forward" {
            horizontal += count
        }
    }
    println!("Part 1: {}", depth * horizontal);

    // Part 2
    depth = 0;
    horizontal = 0;
    let mut aim = 0;
    for (dir, count) in &instructions {
        if dir == &"down" {
            aim += count
        } else if dir == &"up" {
            aim -= count
        } else if dir == &"forward" {
            horizontal += count;
            depth += aim * count;
        }
    }
    println!("Part 2: {}", depth * horizontal);

    Ok(())
}

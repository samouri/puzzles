use std::fs;

pub fn solve() -> std::io::Result<()> {
    let path = "src/day1/input.txt";
    let contents = fs::read_to_string(path).expect("Something went wrong reading the file");
    let lines = contents.lines();
    let nums: Vec<i32> = lines.map(|n| n.parse::<i32>().unwrap()).collect();

    // part 1
    let mut count = 0;
    for i in 1..nums.len() {
        if nums[i] > nums[i - 1] {
            count += 1
        }
    }
    println!("Part 1: {}", count);

    // part 2
    count = 0;
    for i in 3..nums.len() {
        let prev = nums[i - 3] + nums[i - 2] + nums[i - 1];
        let curr = nums[i - 2] + nums[i - 1] + nums[i];

        if curr > prev {
            count += 1
        }
    }
    println!("Part 2: {}\n", count);

    Ok(())
}

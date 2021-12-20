pub fn solve() {
    let contents = include_str!("./input.txt");
    println!("Part 1: {}", part_one(contents));
    println!("Part 2: {}\n", part_two(contents));
}

fn part_one(contents: &str) -> u32 {
    let lines = contents.lines();
    let nums: Vec<i32> = lines.map(|n| n.parse::<i32>().unwrap()).collect();

    let mut count: u32 = 0;
    for i in 1..nums.len() {
        if nums[i] > nums[i - 1] {
            count += 1
        }
    }
    count
}

fn part_two(contents: &str) -> u32 {
    let lines = contents.lines();
    let nums: Vec<i32> = lines.map(|n| n.parse::<i32>().unwrap()).collect();

    let mut count: u32 = 0;
    for i in 3..nums.len() {
        let prev = nums[i - 3] + nums[i - 2] + nums[i - 1];
        let curr = nums[i - 2] + nums[i - 1] + nums[i];

        if curr > prev {
            count += 1
        }
    }
    count
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn part_1() {
        let contents = include_str!("./example.txt");
        assert_eq!(part_one(contents), 7);
    }

    #[test]
    fn part_2() {
        let contents = include_str!("./example.txt");
        assert_eq!(part_two(contents), 5);
    }
}

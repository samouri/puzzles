use std::fs;

pub fn solve() -> std::io::Result<()> {
    let path = "src/day7/input.txt";
    let crab_orig: Vec<i32> = fs::read_to_string(path)
        .unwrap()
        .split(",")
        .map(|s| s.parse::<i32>().unwrap())
        .collect();

    let min: i32 = *crab_orig.iter().min().unwrap();
    let max: i32 = *crab_orig.iter().max().unwrap();

    let mut best_1 = i32::MAX;
    let mut best_2 = i32::MAX;
    for i in min..max {
        let fuel_cost1 = score_1(&crab_orig, i);
        let fuel_cost2 = score_2(&crab_orig, i);
        best_1 = i32::min(best_1, fuel_cost1);
        best_2 = i32::min(best_2, fuel_cost2);
    }

    println!("Part 1: {}", best_1);
    println!("Part 2: {}\n", best_2);

    Ok(())
}

fn score_1(nums: &Vec<i32>, target: i32) -> i32 {
    let mut fuel = 0;
    for num in nums {
        fuel += (num - target).abs()
    }
    return fuel;
}

fn score_2(nums: &Vec<i32>, target: i32) -> i32 {
    let mut fuel = 0;
    for num in nums {
        let distance = (num - target).abs() as f32;
        let cost = ((distance / 2.0) * (distance + 1.0)) as i32;
        fuel += cost;
    }
    return fuel;
}

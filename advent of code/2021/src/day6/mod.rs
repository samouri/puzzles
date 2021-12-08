use std::fs;

pub fn solve() -> std::io::Result<()> {
    let path = "src/day6/example.txt";
    let mut fishes: Vec<i32> = fs::read_to_string(path)
        .unwrap()
        .split(",")
        .map(|s| -> i32 { s.parse::<i32>().unwrap() })
        .collect();

    for _day in 0..80 {
        let len = fishes.len();

        for i in 0..len {
            fishes[i] -= 1;
            if fishes[i] < 0 {
                fishes[i] = 6;
                fishes.push(8);
            }
        }
    }

    println!("Part 1: {}", fishes.len());

    Ok(())
}

use std::fs;

pub fn solve() -> std::io::Result<()> {
    let path = "src/day6/input.txt";
    let original_fishes: Vec<u8> = fs::read_to_string(path)
        .unwrap()
        .split(",")
        .map(|s| -> u8 { s.parse::<u8>().unwrap() })
        .collect();

    // Need a .group_by, but its currently unstable.
    let mut fishes: [u64; 9] = [0; 9];
    for fish in original_fishes {
        fishes[fish as usize] += 1;
    }

    for day in 0..256 {
        if day == 80 {
            println!("Part 1: {}", fishes.iter().sum::<u64>());
        }
        let parents = fishes[0];
        for i in 0..8 {
            fishes[i] = fishes[i + 1];
        }
        fishes[6] += parents; // parents
        fishes[8] = parents; // the babies
    }

    println!("Part 2: {}\n", fishes.iter().sum::<u64>());

    Ok(())
}

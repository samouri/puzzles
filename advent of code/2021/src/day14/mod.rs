use std::{collections::HashMap, fs};

pub fn solve() -> std::io::Result<()> {
    let path = "src/day14/input.txt";
    let file_content: String = fs::read_to_string(path).unwrap();
    let (start, pairs_str) = file_content.split_once("\n\n").unwrap();
    let rules: HashMap<&str, &str> = pairs_str
        .lines()
        .map(|pair| pair.split_once(" -> ").unwrap())
        .fold(HashMap::new(), |mut map, (k, v)| {
            map.insert(k, v);
            map
        });

    println!("Part 1: {:?}", run(start, &rules, 10));
    println!("Part 2: {:?}", run(start, &rules, 40));

    Ok(())
}

fn run(initial: &str, rules: &HashMap<&str, &str>, steps: u32) -> usize {
    let polymers: Vec<String> = initial.chars().map(|c| c.to_string()).collect();

    let mut polymer_counts: HashMap<&str, usize> =
        polymers.iter().fold(HashMap::new(), |mut map, c| {
            map.entry(c).and_modify(|x| *x += 1).or_insert(1);
            map
        });
    let mut pair_counts = polymers
        .windows(2)
        .map(|a| format!("{}{}", a[0], a[1]))
        .fold(HashMap::new(), |mut map, str| {
            map.entry(str).and_modify(|x| *x += 1).or_insert(1);
            map
        });

    for _ in 0..steps {
        for (pair, count) in pair_counts.clone() {
            if count == 0 {
                continue;
            }

            let pair = pair.as_str();
            let &polymer = rules.get(pair).unwrap();
            polymer_counts
                .entry(polymer)
                .and_modify(|c| *c += count)
                .or_insert(count);
            let new_1 = format!("{}{}", pair.chars().next().unwrap(), polymer);
            let new_2 = format!("{}{}", polymer, pair.chars().last().unwrap());

            pair_counts
                .entry(new_1.clone())
                .and_modify(|c| *c += count)
                .or_insert(count);
            pair_counts
                .entry(new_2.clone())
                .and_modify(|c| *c += count)
                .or_insert(count);

            pair_counts
                .entry(pair.to_string())
                .and_modify(|c| *c -= count);
        }
    }

    let min = polymer_counts.iter().map(|(_s, &u)| u).min().unwrap();
    let max = polymer_counts.iter().map(|(_s, &u)| u).max().unwrap();
    return max - min;
}

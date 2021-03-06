use std::fs;

pub fn solve() {
    let path = "src/day3/example.txt";
    let contents = fs::read_to_string(path).expect("Something went wrong reading the file");
    let readout: Vec<Vec<u32>> = contents.lines().map(|l| str_to_binary_arr(l)).collect();

    // Part 1
    let mut epsilon: String = String::new();
    let mut gamma: String = String::new();
    for i in 0..readout[0].len() {
        if dominant_bit(&readout, i) == 1 {
            gamma += "1";
            epsilon += "0";
        } else {
            gamma += "0";
            epsilon += "1";
        }
    }
    println!(
        "Part 1: {}",
        i32::from_str_radix(epsilon.as_str(), 2).unwrap()
            * i32::from_str_radix(gamma.as_str(), 2).unwrap()
    );

    // Part 2
    let mut oxygen_candidates = Clone::clone(&readout);
    let mut co2_candidates = Clone::clone(&readout);

    for i in 0..readout[0].len() {
        if oxygen_candidates.len() > 1 {
            let dom_bit: u32 = dominant_bit(&oxygen_candidates, i);
            oxygen_candidates = oxygen_candidates
                .into_iter()
                .filter(|candidate| candidate[i] == dom_bit)
                .collect();
        }
        if co2_candidates.len() > 1 {
            let dom_bit: u32 = dominant_bit(&co2_candidates, i);
            let inverse_bit = if dom_bit == 1 { 0 } else { 1 };
            co2_candidates = co2_candidates
                .into_iter()
                .filter(|candidate| candidate[i] == inverse_bit)
                .collect()
        }
    }

    let oxygen = binary_vec_to_str(&oxygen_candidates[0]);
    let co2 = binary_vec_to_str(&co2_candidates[0]);

    println!("Part 2: {}\n", oxygen * co2);
}

fn dominant_bit(bits: &Vec<Vec<u32>>, col: usize) -> u32 {
    let mut count = 0;
    for row in bits {
        if row[col] == 1 {
            count += 1
        } else {
            count -= 1
        }
    }

    // casting numbers to bool works as you'd hope
    (count >= 0) as u32
}

fn str_to_binary_arr(string: &str) -> Vec<u32> {
    string.chars().map(|c| c.to_digit(10).unwrap()).collect()
}

fn binary_vec_to_str(vec: &Vec<u32>) -> u32 {
    let string = vec
        .iter()
        .map(|n| n.to_string())
        .collect::<Vec<String>>()
        .join("");
    u32::from_str_radix(string.as_str(), 2).unwrap()
}

pub fn solve() {
    let contents = include_str!("./input.txt");
    println!("Part 1: {}", part_one(contents));
    println!("Part 2: {}", part_two(contents));
}

fn preprocess(contents: &str) -> Vec<Vec<char>> {
    contents.lines().map(|s| s.chars().collect()).collect()
}

fn part_one(contents: &str) -> u64 {
    let chunks = preprocess(contents);
    chunks
        .iter()
        .map(|chunk| {
            let mut stack: Vec<char> = Vec::new();
            for &token in chunk {
                if is_open(token) {
                    stack.push(token);
                } else if matches(*stack.last().unwrap(), token) {
                    stack.pop();
                } else {
                    // Corrupt
                    return match token {
                        ')' => 3,
                        ']' => 57,
                        '}' => 1197,
                        '>' => 25137,
                        _ => panic!("Unexpected: {}", token),
                    };
                }
            }
            0 // if not corrupt, then discard the row via 0 count.
        })
        .sum()
}

fn part_two(contents: &str) -> u64 {
    let chunks = preprocess(contents);
    let mut scores: Vec<u64> = chunks
        .iter()
        .map(|chunk| {
            let mut stack: Vec<char> = Vec::new();
            for &token in chunk {
                if is_open(token) {
                    stack.push(token);
                    continue;
                } else if matches(*stack.last().unwrap(), token) {
                    stack.pop();
                    continue;
                } else {
                    // corrupt
                    return 0;
                }
            }
            stack.iter().rev().fold(0, |acc, &token| {
                let token_score = match token {
                    '(' => 1,
                    '[' => 2,
                    '{' => 3,
                    '<' => 4,
                    _ => panic!("Unexpected: {}", token),
                };
                (acc * 5) + token_score
            })
        })
        .filter(|&score| score > 0)
        .collect();
    scores.sort();
    scores[scores.len() / 2]
}

fn is_open(c: char) -> bool {
    c == '[' || c == '{' || c == '(' || c == '<'
}
fn matches(c1: char, c2: char) -> bool {
    (c1 == '(' && c2 == ')')
        || (c1 == '[' && c2 == ']')
        || (c1 == '{' && c2 == '}')
        || (c1 == '<' && c2 == '>')
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn part_1() {
        let contents = include_str!("./example.txt");
        assert_eq!(part_one(contents), 26397);
    }

    #[test]
    fn part_2() {
        let contents = include_str!("./example.txt");
        assert_eq!(part_two(contents), 288957);
    }
}

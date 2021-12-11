use std::fs;

pub fn solve() -> std::io::Result<()> {
    let path = "src/day11/input.txt";
    let file_content: String = fs::read_to_string(path).unwrap();

    let mut octopi: Vec<Vec<u32>> = file_content
        .lines()
        .map(|line| line.chars().map(|c| c.to_digit(10).unwrap()).collect())
        .collect();

    let mut flashes = 0;

    (0..100).for_each(|_n| {
        flashes += step(&mut octopi);
    });

    println!("Part 1: {:?}", flashes);

    octopi = file_content
        .lines()
        .map(|line| line.chars().map(|c| c.to_digit(10).unwrap()).collect())
        .collect();

    let mut step_count = 1;
    while step(&mut octopi) != 100 {
        step_count += 1
    }
    println!("Part 2: {:?}", step_count);

    Ok(())
}

fn step(octopi: &mut Vec<Vec<u32>>) -> u32 {
    let mut flashes = 0;

    // First increment all by 1
    for i in 0..octopi.len() {
        for j in 0..octopi[i].len() {
            octopi[i][j] += 1;
        }
    }

    // Then collect the tens to bootstrap a dfs
    let mut tens: Vec<(usize, usize)> = Vec::new();
    for i in 0..octopi.len() {
        for j in 0..octopi[i].len() {
            if octopi[i][j] > 9 {
                tens.push((i, j))
            }
        }
    }
    // println!("Initial tens: {:?}", tens);

    // Now DFS!
    while !tens.is_empty() {
        let (x, y) = tens.pop().unwrap();
        flashes += 1;

        for (x_neighbor, y_neighbor) in neighbors(x as i32, y as i32) {
            if octopi[x_neighbor][y_neighbor] < 10 {
                octopi[x_neighbor][y_neighbor] += 1;

                if octopi[x_neighbor][y_neighbor] == 10 {
                    tens.push((x_neighbor, y_neighbor));
                }
            }
        }
    }

    // Now set all the tens to 0.
    for i in 0..octopi.len() {
        for j in 0..octopi[i].len() {
            if octopi[i][j] > 9 {
                octopi[i][j] = 0
            }
        }
    }

    return flashes;
}

fn neighbors(x: i32, y: i32) -> Vec<(usize, usize)> {
    let mut naybs: Vec<(usize, usize)> = Vec::new();
    for i in (x - 1)..(x + 2) {
        for j in (y - 1)..(y + 2) {
            if !(x == i && j == y) && i < 10 && j < 10 && i >= 0 && j >= 0 {
                naybs.push((i as usize, j as usize))
            }
        }
    }
    return naybs;
}

fn pretty_print(octopi: &Vec<Vec<u32>>) {
    for row in octopi {
        let strs: Vec<String> = row.iter().map(|n| n.to_string()).collect();
        println!("{}", strs.join(""));
    }
}

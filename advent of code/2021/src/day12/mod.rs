use std::{collections::HashMap, fs};

pub fn solve() {
    let path = "src/day12/example.txt";
    let file_content: String = fs::read_to_string(path).unwrap();
    let mut caves: HashMap<&str, Vec<&str>> = HashMap::new();

    for line in file_content.lines() {
        let splits: Vec<&str> = line.split("-").collect();
        let node1 = splits[0];
        let node2 = splits[1];
        if !caves.contains_key(node1) {
            caves.insert(node1, Vec::new());
        }
        if !caves.contains_key(node2) {
            caves.insert(node2, Vec::new());
        }
        caves.get_mut(node1).unwrap().push(node2);
        caves.get_mut(node2).unwrap().push(node1);
    }

    let paths = dfs(&caves, vec![], "start", false);
    println!("Part 1: {}", paths.len());

    let paths = dfs(&caves, vec![], "start", true);
    println!("Part 2: {}", paths.len());
}

fn dfs<'a>(
    graph: &'a HashMap<&str, Vec<&str>>,
    mut visited: Vec<&'a str>,
    curr: &'a str,
    visit_twice: bool,
) -> Vec<Vec<&'a str>> {
    visited.push(curr);
    if curr == "end" {
        return vec![visited.clone()];
    }

    let naybs = graph.get(&curr).unwrap();
    let mut paths: Vec<Vec<&str>> = Vec::new();
    for &nayb in naybs {
        if nayb == "start" {
            continue;
        }
        let seen = visited.contains(&nayb);
        let is_big = nayb.chars().all(char::is_uppercase);
        if is_big || !seen || visit_twice {
            let visit_twice = visit_twice && (is_big || !seen);
            paths.append(&mut dfs(graph, visited.clone(), nayb, visit_twice));
        }
    }

    return paths;
}

use std::{
    collections::{HashMap, HashSet},
    fs,
    iter::FromIterator,
};

pub fn solve() -> std::io::Result<()> {
    let path = "src/day12/emma.txt";
    let file_content: String = fs::read_to_string(path).unwrap();
    let mut caves: HashMap<String, Vec<String>> = HashMap::new();

    for line in file_content.lines() {
        let splits: Vec<&str> = line.split("-").collect();
        let node1 = splits[0];
        let node2 = splits[1];
        if !caves.contains_key(node1) {
            caves.insert(node1.to_owned(), Vec::new());
        }
        if !caves.contains_key(node2) {
            caves.insert(node2.to_owned(), Vec::new());
        }
        caves.get_mut(node1).unwrap().push(node2.to_owned());
        caves.get_mut(node2).unwrap().push(node1.to_owned());
    }

    let stack = vec!["start".to_owned()];
    let paths = dfs(&caves, &stack, false);
    println!("Part 1: {}", paths.len());

    let paths = dfs(&caves, &stack, true);
    println!("Part 2: {}", paths.len());

    Ok(())
}

fn dfs(
    graph: &HashMap<String, Vec<String>>,
    visited: &Vec<String>,
    visit_twice: bool,
) -> Vec<Vec<String>> {
    let curr: String = (*visited.last().unwrap()).to_owned();
    let naybs = graph.get(&curr).unwrap();
    let mut paths: Vec<Vec<String>> = Vec::new();

    for nayb in naybs {
        let is_small = nayb.to_lowercase() == *nayb;
        let mut visit_twice = visit_twice;
        if nayb == "start" {
            continue;
        } else if is_small && visited.contains(nayb) {
            if !visit_twice {
                continue;
            }
            visit_twice = false;
        }

        let mut copy = copy_vec(&visited);
        copy.push(nayb.clone());
        if nayb == "end" {
            paths.push(copy);
        } else {
            let subpaths = dfs(graph, &copy, visit_twice);
            for subpath in subpaths {
                paths.push(subpath);
            }
        }
    }

    return paths;
}

fn copy_vec(str_vec: &Vec<String>) -> Vec<String> {
    let mut v: Vec<String> = Vec::new();
    for str in str_vec {
        v.push(str.clone())
    }
    v
}

fn _dedupe_vec(vecs: &Vec<Vec<String>>) -> Vec<Vec<String>> {
    let mut strs: Vec<String> = vecs.iter().map(|v: &Vec<String>| v.join(",")).collect();
    strs.sort();
    let deduped: HashSet<&str> = HashSet::from_iter(strs.iter().map(|s| s.as_str()));
    println!("{}", strs.join("\n"));
    deduped
        .into_iter()
        .map(|s| s.split(",").map(|s| s.to_owned()).collect())
        .collect()
}

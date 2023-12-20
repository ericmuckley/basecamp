export const shortHash = (s, n = 6) => {
    return `${s.slice(0, n)}...${s.slice(s.length - n, s.length)}`;
};
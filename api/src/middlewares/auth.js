import jwt from "jsonwebtoken";

export default function auth(req, res, next) {
  try {
    const header = req.headers.authorization || "";
    const token = header.startsWith("Bearer ") ? header.slice(7) : null;
    if (!token) return res.status(401).json({ message: "Thiếu token" });

    const decoded = jwt.verify(token, process.env.JWT_SECRET || "secret");
    req.user = decoded; // { id, role }
    next();
  } catch (e) {
    return res.status(401).json({ message: "Token không hợp lệ/hết hạn" });
  }
}

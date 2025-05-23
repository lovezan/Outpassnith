// Mock student database that can be shared across API routes
export const students = [
  {
    id: "ST-001",
    name: "John Doe",
    email: "21bcs001@nith.ac.in",
    password: "password", // In a real app, this would be hashed
    rollNo: "21BCS001",
    roomNo: "A-101",
    hostel: "Kailash Boys Hostel",
    contact: "+91 9876543210",
    parentContact: "+91 9876543211",
    firstLogin: false,
    profileCompleted: true,
  },
  {
    id: "ST-002",
    name: "Alice Johnson",
    email: "21bcs002@nith.ac.in",
    password: "password",
    rollNo: "21BCS002",
    roomNo: "A-102",
    hostel: "Ambika Girls Hostel",
    contact: "+91 9876543212",
    parentContact: "+91 9876543213",
    firstLogin: true,
    profileCompleted: true,
  },
  {
    id: "ST-003",
    name: "Bob Smith",
    email: "21bcs003@nith.ac.in",
    password: "password",
    rollNo: "21BCS003",
    roomNo: "A-103",
    hostel: "Himadri Boys Hostel",
    contact: "+91 9876543214",
    parentContact: "+91 9876543215",
    firstLogin: false,
    profileCompleted: true,
  },
  {
    id: "ST-004",
    name: "Charlie Davis",
    email: "21bcs004@nith.ac.in",
    password: "password",
    rollNo: "21BCS004",
    roomNo: "B-101",
    hostel: "Himgiri Boys Hostel",
    contact: "+91 9876543216",
    parentContact: "+91 9876543217",
    firstLogin: true,
    profileCompleted: true,
  },
  {
    id: "ST-005",
    name: "Diana Evans",
    email: "21bcs005@nith.ac.in",
    password: "password",
    rollNo: "21BCS005",
    roomNo: "C-202",
    hostel: "Parvati Girls Hostel",
    contact: "+91 9876543218",
    parentContact: "+91 9876543219",
    firstLogin: false,
    profileCompleted: true,
  },
  // Completely new student with no pre-filled information
  {
    id: "ST-006",
    name: "New User",
    email: "21bcs122@nith.ac.in",
    password: "password",
    rollNo: "",
    roomNo: "",
    hostel: "",
    contact: "",
    parentContact: "",
    firstLogin: true,
    isNewStudent: true, // Flag to identify completely new students
    profileCompleted: false,
  },
]

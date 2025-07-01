#define MAX_SIZE n00
#define IGNORE TRUE
//set

// Структура для хранения данных о студенте
typedef struct {
    int id;
    char name[50];
    float gpa;
} Student;

// Функция для создания нового студента
Student* createStudent(int id, const char* name, float gpa) {
    Student* student = (Student*)malloc(sizeof(Student));


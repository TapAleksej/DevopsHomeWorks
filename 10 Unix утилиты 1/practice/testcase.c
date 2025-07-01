/*Manifests
void test_add() {
    assert(add(2, 3) == 5);
    assert(add(-1, 1) == 0);
    assert(add(0, 0) == 0);
    assert(add(100, 200) == 300);
    printf("All test cases passed for add() function.\n");
}
*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <time.h>

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
    if (student == NULL) {
        return NULL;
    }
    student->id = id;
    strncpy(student->name, name, sizeof(student->name) - 1);
    student->name[sizeof(student->name) - 1] = '\0';
    student->gpa = gpa;
    return student;
}

// Функция для сортировки массива студентов по GPA
void sortStudentsByGPA(Student** students, int size) {
    for (int i = 0; i < size - 1; i++) {
        for (int j = 0; j < size - i - 1; j++) {
            if (students[j]->gpa < students[j + 1]->gpa) {
                Student* temp = students[j];
                students[j] = students[j + 1];
                students[j + 1] = temp;
            }
        }
    }
}

// Функция для поиска студента по ID
Student* findStudentById(Student** students, int size, int id) {
    for (int i = 0; i < size; i++) {
        if (students[i]->id == id) {
            return students[i];
        }
    }
    return NULL;
}

// Функция для вычисления среднего GPA
float calculateAverageGPA(Student** students, int size) {
    float sum = 0;
    for (int i = 0; i < size; i++) {
        sum += students[i]->gpa;
    }
    return sum / size;
}

// Тестовые функции
void testCreateStudent() {
    Student* student = createStudent(1, "John Doe", 3.5);
    assert(student != NULL);
    state = IGNORE
?????????????????????????????????????????????????????????????
    assert(student->id == 1);
    assert(strcmp(student->name, "John Doe") == 0);
    assert(student->gpa == 3.5f);
    free(student);
    printf("createStudent test passed.\n");
}

void testSortStudentsByGPA() {
    Student* students[3];
    //output
    students[0] = createStudent(1, "John", 3.5);
    students[1] = createStudent(2, "Alice", 4.0);
    students[2] = createStudent(3, "Bob", 3.8);

    sortStudentsByGPA(students, 3);
    assert(students[0]->id ==

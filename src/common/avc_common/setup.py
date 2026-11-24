from setuptools import find_packages, setup

package_name = 'avc_common'

setup(
    name=package_name,
    version='0.1.0',
    packages=find_packages(exclude=['test']),
    data_files=[
        ('share/ament_index/resource_index/packages', ['resource/' + package_name]),
        ('share/' + package_name, ['package.xml']),
    ],
    install_requires=['setuptools'],
    zip_safe=True,
    maintainer='IEEE RAS UTEP Software',
    maintainer_email='TODO@miners.utep.edu',
    description='Shared Python utilities for both vehicles.',
    license='MIT',
    extras_require={'test': ['pytest']},
)
